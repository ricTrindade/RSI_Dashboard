//+------------------------------------------------------------------+
//|                                                 RSIDashBoard.mq4 |
//|                                Copyright 2022, ©Ricardo Trindade |
//|                      https://www.linkedin.com/in/costa-trindade/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, ©Ricardo Trindade"
#property link      "https://www.linkedin.com/in/costa-trindade/"
#property version   "1.00"
#property strict
#property indicator_chart_window

//***********************************
//Include External Libraries
//***********************************
#include <Controls/Dialog.mqh>
#include <Controls/Button.mqh>  
#include <Controls/Label.mqh>

//***********************************
//Declare Objects
//***********************************
CAppDialog RsiAppDialog;
CPanel OurPanelArray[6][7];
CButton CButtonArray[6];
CLabel OurLabelArray[6][7];
CEdit PeriodEdit,OverBoughtEdit,OverSoldEdit;

//***********************************
//Global Variables
//***********************************
string SymbolArray[6];
string PeriodLabel[7] ={"D1","4H","1H","30M","15M","5M","1M"};

int PeriodInt[7] ={PERIOD_D1, 
                   PERIOD_H4, 
                   PERIOD_H1, 
                   PERIOD_M30, 
                   PERIOD_M15, 
                   PERIOD_M5, 
                   PERIOD_M1};

//RSI period
int RSI_period;// = 14;
int OverBought;// = 70;
int OverSold;// = 20;
//-----------
//Button Names
string ButtonNames[6] = {"AUD",
                         "EUR",
                         "GBP",
                         "CAD",
                         "JPY",
                         "CHF"};

//-----------
//RSI Values
double RSI_Array[6][7];

//---------------------------
//Input from the user
//---------------------------
extern string prefix = "";
extern string suffix = "";

//---------------------------
//Window, Obj and tab Control
//---------------------------

//-----------
//Main Window
int AppDialogWidth=190;
int AppDialogHeigh=230;
int AppDialogTop = 0;
int AppDialogLeft = 0;

//-----------
//Panels
int panelWidth=30;
int panelHeigh=25;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   //..............................
   //Populate Symbol Array      
   //..............................
   PopulateSymbolArray();
   
   //..............................
   //Main Interface - MainWindow      
   //..............................
   RsiAppDialog.Create(0,
                       "RsiAppDialog",
                       0,
                       AppDialogLeft,
                       AppDialogTop,
                       AppDialogLeft + AppDialogWidth,
                       AppDialogTop + AppDialogHeigh);
   
   RsiAppDialog.Caption("      RSI      /");
   //..............................
   //Panel     
   //..............................
   CreatePanels();
   
   //..............................
   //Buttons     
   //..............................
   CreateButtons();
   
   //..............................
   //Edit Boxes     
   //..............................
   CreateEdits();
   
   //..............................
   //Run Everything      
   //..............................
   RsiAppDialog.Run();
   
   //..............................
   //RSI Array      
   //..............................
   ArrayFill(RSI_Array,0,42,50);
   //Every element of the array is initialised at the value of '50'
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator De-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   RsiAppDialog.Destroy(reason);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void OnTick() {
//---

   UpdateRSIValues();
   SetPanelColors();
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   
   //..............................
   //Enable Controls of Main Window
   //..............................               
   RsiAppDialog.OnEvent(id,lparam,dparam,sparam);
   
   //..............................
   //Currency BUTTONS
   //..............................
   if(id==CHARTEVENT_OBJECT_CLICK)
      ChangeSymbols(sparam);
      
   //..............................
   //Change Edit boxes
   //..............................
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
   UpdateParameters(sparam);
}

//+------------------------------------------------------------------+
//| Custom function                                                  |
//+------------------------------------------------------------------+

//..............................
//Create the Panels
//..............................
void CreatePanels() {

   int left = 0;
   int right = left + panelWidth;
   int top = 0;
   int bottom = top + panelHeigh;
   
   for(int i=0; i<6; i++) {
      for(int j=0; j<7; j++) {
      
         //Panel
         OurPanelArray[i][j].Create(0,string(i)+string(j),0,left,top,right,bottom);
         OurPanelArray[i][j].ColorBackground(clrYellow);
         OurPanelArray[i][j].ColorBorder(clrBlack);
         RsiAppDialog.Add(OurPanelArray[i][j]);
         
         //Label
         OurLabelArray[i][j].Create(0,ButtonNames[i]+PeriodLabel[j],0,left+2,top+5,right,bottom);//Remember, objects have to have different Names
         OurLabelArray[i][j].Text(PeriodLabel[j]);
         OurLabelArray[i][j].Font("Arial Bold");
         OurLabelArray[i][j].FontSize(10);
         RsiAppDialog.Add(OurLabelArray[i][j]);
         
         //Increment
         top += panelHeigh;
         bottom += panelHeigh;
      }
      
      //Increment
      top = 0;
      bottom = top + panelHeigh;
      left += panelWidth;
      right = left + panelWidth;
   }
}

//..............................
//Create Buttons (it also adds labels)
//..............................
void CreateButtons() {
   
   int buttonWidth = panelWidth;
   int top = panelHeigh*7;
   int bottom = panelHeigh*8;
   int left = 0;
   int right = left+buttonWidth;
   
   for(int i=0; i<6; i++){
   
      CButtonArray[i].Create(0,ButtonNames[i],0,left,top,right,bottom);
      CButtonArray[i].Text(ButtonNames[i]);
      CButtonArray[i].Font("Arial Bold");
      CButtonArray[i].FontSize(8);
      RsiAppDialog.Add(CButtonArray[i]);
      
      left += buttonWidth;
      right += buttonWidth;
   }
}

//..............................
//Funtion to change symbols
//.............................. 
void ChangeSymbols(string sparam) {
   
   if(sparam=="AUD") ChartSetSymbolPeriod(0,SymbolArray[0],0);
   if(sparam=="EUR") ChartSetSymbolPeriod(0,SymbolArray[1],0);
   if(sparam=="GBP") ChartSetSymbolPeriod(0,SymbolArray[2],0);
   if(sparam=="CAD") ChartSetSymbolPeriod(0,SymbolArray[3],0);
   if(sparam=="JPY") ChartSetSymbolPeriod(0,SymbolArray[4],0);
   if(sparam=="CHF") ChartSetSymbolPeriod(0,SymbolArray[5],0);
}

//..............................
//Populate Symbol Array
//..............................
void PopulateSymbolArray() {

   SymbolArray[0] = prefix+"AUDUSD"+suffix;
   SymbolArray[1] = prefix+"EURUSD"+suffix;
   SymbolArray[2] = prefix+"GBPUSD"+suffix;
   SymbolArray[3] = prefix+"USDCAD"+suffix;
   SymbolArray[4] = prefix+"USDJPY"+suffix;
   SymbolArray[5] = prefix+"USDCHF"+suffix;
}

//..............................
//Update RSI values
//..............................
void UpdateRSIValues() {
   
   for(int i=0; i<6; i++) {
      for(int j=0; j<7; j++) {
         RSI_Array[i][j] = iRSI(SymbolArray[i],PeriodInt[j],RSI_period,PRICE_CLOSE,0);
      }
   }      
}

//..............................
//SetPanelColors
//..............................
void SetPanelColors() {

   for(int i=0; i<6; i++) {
      for(int j=0; j<7; j++) {
         if(RSI_Array[i][j]>OverBought) OurPanelArray[i][j].ColorBackground(clrRed);
         else if(RSI_Array[i][j]<OverSold) OurPanelArray[i][j].ColorBackground(clrGreen);
         else OurPanelArray[i][j].ColorBackground(clrYellow);
      }
   }        
}

//..............................
//Create Edit Boxes
//..............................
void CreateEdits() {
   
   //Period
   PeriodEdit.Create(0,"PeriodEdit",0,0,0,20,20);
   RsiAppDialog.Add(PeriodEdit);
   PeriodEdit.Shift(3,-21);
   PeriodEdit.FontSize(8);
   PeriodEdit.Text(string(RSI_period));
   
   //OverBought 
   OverBoughtEdit.Create(0,"OverBoughtEdit",0,0,0,20,20);
   RsiAppDialog.Add(OverBoughtEdit);
   OverBoughtEdit.Shift(47,-21);
   OverBoughtEdit.FontSize(8);
   OverBoughtEdit.Text(string(OverBought));
   
   //OverSold
   OverSoldEdit.Create(0,"OverSoldEdit",0,0,0,20,20);
   RsiAppDialog.Add(OverSoldEdit);
   OverSoldEdit.Shift(78,-21);
   OverSoldEdit.FontSize(8);
   OverSoldEdit.Text(string(OverSold));
}

//..............................
//Update Parameters of Edit Boxes
//..............................
void UpdateParameters(string sparam) {

   if(sparam=="PeriodEdit") {
      RSI_period = (int)PeriodEdit.Text();
      UpdateRSIValues();
      SetPanelColors();
   } 
   
   else if(sparam=="OverBoughtEdit") {
      OverBought = (int)OverBoughtEdit.Text();
      UpdateRSIValues();
      SetPanelColors();
   }   
   
   else if(sparam=="OverSoldEdit") {
      OverSold = (int)OverSoldEdit.Text();
      UpdateRSIValues();
      SetPanelColors();
   }  
}
//+------------------------------------------------------------------+
