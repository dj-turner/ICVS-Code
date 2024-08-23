#include <LiquidCrystal.h>
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define TWOPI 6.2831853
#define POT A1

#define OPT_TESTCHAN 1
#define OPT_WAVEFORM 2
#define OPT_FREQ 3
#define OPT_REFCHAN 4
#define OPT_REFLEVEL 5
#define OPT_TESTPHASE 6
#define OPT_DIAG 7
#define OPT_MAX 7

//LCD AND BUTTONS-----------------------------------------------------------------------
// Pins in use
#define BUTTON_ADC_PIN           A0  // A0 is the button ADC input
#define LCD_BACKLIGHT_PIN         10  // D10 controls LCD backlight
// ADC readings expected for the 5 buttons on the ADC input
#define RIGHT_10BIT_ADC           0  // right
#define UP_10BIT_ADC            145  // up
#define DOWN_10BIT_ADC          329  // down
#define LEFT_10BIT_ADC          505  // left
#define SELECT_10BIT_ADC        741  // right
#define BUTTONHYSTERESIS         10  // hysteresis for valid button sensing window
//return values for ReadButtons()
#define BUTTON_NONE               0  // 
#define BUTTON_RIGHT              1  // 
#define BUTTON_UP                 2  // 
#define BUTTON_DOWN               3  // 
#define BUTTON_LEFT               4  // 
#define BUTTON_SELECT             5  // 
// return values for ReadKeyboard()
#define KEY_NONE                  0  //
#define KEY_UP                    105 // i  //65  // 
#define KEY_DOWN                  107 // k  //66  // 
#define KEY_RIGHT                 108 // l  //67  // 
#define KEY_LEFT                  106 // j  //68  // 
#define KEY_SELECT                13  // 
byte keyJustPressed  = false;         //this will be true after a ReadKeyboard() call if triggered
byte keyJustReleased = false;         //this will be true after a ReadKeyboard() call if triggered
byte keyWas          = KEY_NONE;   //used by ReadKeyboard() for detection of button events
//some example macros with friendly labels for LCD backlight/pin control, tested and can be swapped into the example code as you like
#define LCD_BACKLIGHT_OFF()     digitalWrite( LCD_BACKLIGHT_PIN, LOW )
#define LCD_BACKLIGHT_ON()      digitalWrite( LCD_BACKLIGHT_PIN, HIGH )
#define LCD_BACKLIGHT(state)    { if( state ){digitalWrite( LCD_BACKLIGHT_PIN, HIGH );}else{digitalWrite( LCD_BACKLIGHT_PIN, LOW );} }

byte buttonJustPressed  = false;         //this will be true after a ReadButtons() call if triggered
byte buttonJustReleased = false;         //this will be true after a ReadButtons() call if triggered
byte buttonWas          = BUTTON_NONE;   //used by ReadButtons() for detection of button events

//Init the LCD library with the LCD pins to be used
LiquidCrystal lcd( 8, 9, 4, 5, 6, 7 );   //Pins for the freetronics 16x2 LCD shield. LCD: ( RS, E, LCD-D4, LCD-D5, LCD-D6, LCD-D7 )


int refChan = 1; //0 for green, 1 for red
int testChan = 0; //as above. for calibration this is the channel you are calibrating
int mode = 1; // 0 MENU, 1 RUN
double t;
unsigned long time;
double refWave;
double testWave;
double refLin;
double testLin;
int potVal = 123; // was int potVal;
double testAmp;
double refAmp;
double testPhase;
long int refLevelSetting = 1024; //0 for calibration, 1023 for HFP
int testPhaseSetting = 180;
byte option;
byte wform;
int freq = 2;


//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
void setup() {
  Serial.begin(9600);

  pinMode( POT, INPUT );         //ensure A0 is an input

  //LCD and buttons stuff
  pinMode( BUTTON_ADC_PIN, INPUT );         //ensure A0 is an input
  digitalWrite( BUTTON_ADC_PIN, LOW );      //ensure pullup is off on A0
  //lcd backlight control
  digitalWrite( LCD_BACKLIGHT_PIN, HIGH );  //backlight control pin D3 is high (on)
  pinMode( LCD_BACKLIGHT_PIN, OUTPUT );     //D3 is an output
  //set up the LCD number of columns and rows: 
  lcd.begin( 16, 2 );
  //Print some initial text to the LCD.
  lcd.setCursor( 0, 0 );   //top left
  lcd.print( "Hello!" );
  delay(1000);


  //PWM stuff
  pwm.begin();
  pwm.setPWMFreq(1600);  // This is the maximum PWM frequency

  // save I2C bitrate
  uint8_t twbrbackup = TWBR;
  // must be changed after calling Wire.begin() (inside pwm.begin())
  TWBR = 12; // upgrade to 400KHz!

  option = OPT_WAVEFORM;
  wform = 2; // 0 for sin for HFP, 1 for mean for calibrating, 2 for max for calibrating

}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

void loop() {
  byte button;
  byte key;


  if (mode==0)  //menu
  {
    key = ReadKeyboard();
    if (keyJustPressed)
    {
      Serial.write("Keypress registered in menu mode\r\n");
      }
    if (keyJustPressed && key==KEY_LEFT)
    {
      Serial.write("key==KEY_LEFT\r\n");
      Serial.println(option);
      option = option - 1;
      Serial.println(option);
    }
    if (keyJustPressed && key==KEY_RIGHT)
    {
      option = option + 1;
    }
    if (option<1)
    {
      option=OPT_MAX;
    }
    if (option>OPT_MAX)
    {
      option=1;
    }
    if (keyJustPressed && key==KEY_SELECT)
    {
      mode = 1;
      setAllChannels(0);
      Serial.write("mode set to run\r\n");
    }
    //clearKeyboard();

    switch (option)
    {
    case OPT_TESTCHAN:
      {
        lcd.setCursor( 0,  0 );
        lcd.print( "Test channel    " );
        lcd.setCursor( 0,  1 );
        lcd.print( "                " );
        lcd.setCursor( 0,  1 );
        lcd.print( testChan );
        if (keyJustPressed && key==KEY_UP )
        {
          testChan = testChan + 1;
          if (testChan==refChan)
          {
            testChan = testChan + 1;
          }
        }
        if (keyJustPressed && key==KEY_DOWN)
        {
          testChan = testChan - 1;
        }
        if (testChan==refChan)
        {
          testChan = testChan - 1;
        }
        if (testChan<0)
        {
          testChan = 16;
        }
        if (testChan>16)
        {
          testChan = 0;
        }
        break;
      }
    case OPT_REFCHAN:
      {
        lcd.setCursor( 0,  0 );
        lcd.print( "Ref channel    " );
        lcd.setCursor( 0,  1 );
        lcd.print( "                " );
        lcd.setCursor( 0,  1 );
        lcd.print( refChan );
        if (keyJustPressed && key==KEY_UP )
        {
          refChan = refChan + 1;

        }
        if (keyJustPressed && key==KEY_DOWN)
        {
          refChan = refChan - 1;
        }
        if (refChan<0)
        {
          refChan = 16;
        }
        if (refChan>16)
        {
          refChan = 0;
        }
        break;
      }
    case OPT_WAVEFORM:
      {
        lcd.setCursor( 0,  0 );
        lcd.print( "Waveform        " );
        lcd.setCursor( 0,  1 );
        lcd.print( "                " );
        lcd.setCursor( 0,  1 );
        if (wform==0) {
          lcd.print( "sin             " ); 
        } 
        else if (wform==1) {
          lcd.print( "mean            " ); 
        }
        else if (wform==2) {
          lcd.print( "max             " );
        }

        if (keyJustPressed && (key==KEY_UP || key==KEY_DOWN))
        {
          wform = wform + 1;
          if (wform>2) {
            wform = 0;
          }
          if (wform<0) {
            wform = 2;
          }
        }
        break;
      }
    case OPT_FREQ:
      {
        lcd.setCursor( 0,  0 );
        lcd.print( "Frequency       " );
        lcd.setCursor( 0,  1 );
        lcd.print( "                " );
        lcd.setCursor( 0,  1 );
        lcd.print( freq );
        if (keyJustPressed && key==KEY_UP )
        {
          freq = freq + 1;
        }
        if (keyJustPressed && key==KEY_DOWN)
        {
          freq = freq - 1;
        }
        if (freq<1)
        {
          freq = 1;
        }
        if (freq>100)
        {
          freq = 100;
        }

        break;
      }
    case OPT_REFLEVEL:
      {
        lcd.setCursor( 0,  0 );
        lcd.print( "Ref amplitude   " );
        lcd.setCursor( 0,  1 );
        lcd.print( "                " );
        lcd.setCursor( 0,  1 );
        lcd.print( refLevelSetting );
        if (keyJustPressed && key==KEY_UP )
        {
          refLevelSetting = refLevelSetting + 1;
        }
        if (keyJustPressed && key==KEY_DOWN)
        {
          refLevelSetting = refLevelSetting - 1;
        }
        if (refLevelSetting<0)
        {
          refLevelSetting = 1023;
        }
        if (refLevelSetting>1023)
        {
          refLevelSetting = 0;
        }

        break;
      }
      case OPT_TESTPHASE:
      {
        lcd.setCursor( 0,  0 );
        lcd.print( "Test phase   " );
        lcd.setCursor( 0,  1 );
        lcd.print( "                " );
        lcd.setCursor( 0,  1 );
        lcd.print( testPhaseSetting );
        if (keyJustPressed && key==KEY_UP )
        {
          testPhaseSetting = testPhaseSetting + 1;
        }
        if (keyJustPressed && key==KEY_DOWN)
        {
          testPhaseSetting = testPhaseSetting - 1;
        }
        if (testPhaseSetting<0)
        {
          testPhaseSetting = 359;
        }
        if (testPhaseSetting>359)
        {
          testPhaseSetting = 0;
        }

        break;
      }
    case OPT_DIAG:
      {
        lcd.setCursor( 0,  0 );
        lcd.print( "Diagnostic      " );
        lcd.setCursor( 0,  1 );
        lcd.print( "                " );
        setAllChannels(4095);

        break;
      }



    }

    clearKeyboard();
  }
  else if (mode==1) //running
  {
    key = ReadKeyboard();
    if (keyJustPressed && key==KEY_SELECT)
    {
      clearKeyboard();

      mode = 0;
      setAllChannels(0);
      Serial.write("mode set to menu\r\n");
    }    

    lcd.setCursor( 0,  0 );
    lcd.print( "Test amplitude" );

    t+=0.1;
    time = micros();

    /*Replace potentiometer*/

    if (keyJustPressed)
    {
      
      Serial.write("Keypress registered in run mode\r\n");
      
      if (key == 'q' )
      {
        potVal = potVal - 100;
      }
      if (key == 'w')
      {
        potVal = potVal - 10;
      }
      if (key == 'e')
      {
        potVal = potVal - 1;
      }
      if (key == 'r')
      {
        potVal = potVal + 1;
      }
      if (key == 't')
      {
        potVal = potVal + 10;
      }
      if (key == 'y')
      {
        potVal = potVal + 100;
      }
      if (potVal < 1)
      {
        potVal = 1;
      }
      if (potVal > 1023)
      {
        potVal = 1023;
      }
      
      Serial.println("potVal: ");
      Serial.println(potVal);         // print current test amplitude

    }
    
    //Serial.println(potVal);
    lcd.setCursor( 0, 1 );
    lcd.print( "                " );
    lcd.setCursor( 0, 1 );
    lcd.print( potVal );

    //Todo: convert pot setting into linear LED output.
    testAmp = (double)potVal/1023.0;
    refAmp = (double)refLevelSetting/1024.0;

    //Convert test phase setting to radians
    testPhase = (double)testPhaseSetting/360.0*TWOPI;

    //Calculate flicker waveform values
    if (wform == 0)
    {
      testWave = (sin(TWOPI*(float)freq*(float)time/1000000+testPhase)/2.0+0.5)*testAmp;
      refWave  = (sin(TWOPI*(float)freq*(float)time/1000000)/2.0+0.5)*refAmp;
    } 
    else if (wform == 1)
    {
      testWave = testAmp*0.5;
      refWave = refAmp*0.5;
    }
    else if (wform == 2)
    {
      testWave = testAmp;
      refWave = refAmp;
    } 

    //Convert to PWM values and write
    refLin = refWave;
    testLin = testWave;
    pwm.setPWM(refChan, 0, (int)(refLin*4095) );
    pwm.setPWM(testChan, 0, (int)(testLin*4095) );

    delay(1);
  }
}

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

double linearise(double unlin)
{
  double lin;

  lin = unlin;
  return lin;
}

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

void setAllChannels(int level)
{
  for (int chan=0; chan<16; chan++ ) {
    pwm.setPWM(chan, 0, level );
  }

}

/*---------------------------------------------------------------------------
 Detect the button pressed and return the value
 Uses global values buttonWas, buttonJustPressed, buttonJustReleased.
 
 Almost completely copied from example
 --------------------------------------------------------------------------------------*/
byte ReadButtons()
{
  unsigned int buttonVoltage;
  byte button = BUTTON_NONE;   // return no button pressed if the below checks don't write to btn

  //read the button ADC pin voltage
  buttonVoltage = analogRead( BUTTON_ADC_PIN );
  //sense if the voltage falls within valid voltage windows
  if( buttonVoltage < ( RIGHT_10BIT_ADC + BUTTONHYSTERESIS ) )
  {
    button = BUTTON_RIGHT;
  }
  else if(   buttonVoltage >= ( UP_10BIT_ADC - BUTTONHYSTERESIS )
    && buttonVoltage <= ( UP_10BIT_ADC + BUTTONHYSTERESIS ) )
  {
    button = BUTTON_UP;
  }
  else if(   buttonVoltage >= ( DOWN_10BIT_ADC - BUTTONHYSTERESIS )
    && buttonVoltage <= ( DOWN_10BIT_ADC + BUTTONHYSTERESIS ) )
  {
    button = BUTTON_DOWN;
  }
  else if(   buttonVoltage >= ( LEFT_10BIT_ADC - BUTTONHYSTERESIS )
    && buttonVoltage <= ( LEFT_10BIT_ADC + BUTTONHYSTERESIS ) )
  {
    button = BUTTON_LEFT;
  }
  else if(   buttonVoltage >= ( SELECT_10BIT_ADC - BUTTONHYSTERESIS )
    && buttonVoltage <= ( SELECT_10BIT_ADC + BUTTONHYSTERESIS ) )
  {
    button = BUTTON_SELECT;
  }
  //handle button flags for just pressed and just released events
  if( ( buttonWas == BUTTON_NONE ) && ( button != BUTTON_NONE ) )
  {
    //the button was just pressed, set buttonJustPressed, this can optionally be used to trigger a once-off action for a button press event
    //it's the duty of the receiver to clear these flags if it wants to detect a new button change event
    buttonJustPressed  = true;
    buttonJustReleased = false;
  }
  if( ( buttonWas != BUTTON_NONE ) && ( button == BUTTON_NONE ) )
  {
    buttonJustPressed  = false;
    buttonJustReleased = true;
  }

  //save the latest button value, for change event detection next time round
  buttonWas = button;

  return( button );
}

void clearButtons()
{
  if( buttonJustPressed )
    buttonJustPressed = false;
  if( buttonJustReleased )
    buttonJustReleased = false;
  return;
}


/* ReadKeyboard() -------------------------------------------------------*/
byte ReadKeyboard()
{
  byte key = KEY_NONE;   // return no key pressed if the below checks don't write to btn

  /*  check if data has been sent from the computer: */
  if (Serial.available()) {
    key = Serial.read();       /* read the most recent byte */
    Serial.println("key: ");   /*ECHO the value that was read, back to the serial port. */
    Serial.println(key);
  }

  //handle key flags for just pressed and just released events
  if ( ( keyWas == KEY_NONE ) && ( key != KEY_NONE ) )
  {
    //the key was just pressed, set keyJustPressed, this can optionally be used to trigger a once-off action for a key press event
    //it's the duty of the receiver to clear these flags if it wants to detect a new key change event
    keyJustPressed  = true;
    keyJustReleased = false;
    Serial.write("keyJustPressed set to true \r\n");
  }
  if ( ( keyWas != KEY_NONE ) && ( key == KEY_NONE ) )
  {
    keyJustPressed  = false;
    keyJustReleased = true;
  }

  //save the latest key value, for change event detection next time round
  keyWas = key;

  Serial.write(keyJustPressed);

  return ( key );

}

void clearKeyboard()
{
  if( keyJustPressed )
    keyJustPressed = false;
  if( keyJustReleased )
    keyJustReleased = false;
  return;
}
