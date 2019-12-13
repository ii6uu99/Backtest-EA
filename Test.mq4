//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                                   Awang Suryawan |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Awang Suryawan"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define MAGICNUM 865182
#define FLAT 0
#define LONG 1
#define SHORT 2

//INPUT
sinput double RiskPercent = 2;
sinput double initialDeposit = 50000;
sinput int TakeProfitPercent = 100;
sinput int StopLossPercent = 150;
sinput int ATRPeriod = 14;

// GLOBAL VARIABLES:
double myATR;
double stopLoss;
double takeProfit;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+


//LOT
double getFractionLots(double stopInPips){
   double lot = 0.01;
   
   double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
   if(Point == 0.001 || Point == 0.00001){ 
      tickValue *= 10;
   }
   
   double lotSize = MarketInfo(Symbol(),MODE_LOTSIZE);
   
   double LotStep = MarketInfo(_Symbol, MODE_LOTSTEP);
   int    Decimals = 0;
   if(LotStep == 0.1){
      Decimals = 1;
   }
   else if(LotStep == 0.01){
      Decimals = 2;
   }

   double accountValue = AccountBalance();
   double valuePerPip = (accountValue*(RiskPercent/100))/stopInPips;
   lot = valuePerPip/tickValue;
   lot = StrToDouble(DoubleToStr(lot,Decimals));
   
   double myMaxLot = MarketInfo(_Symbol, MODE_MAXLOT);
   double myMinLot = MarketInfo(_Symbol, MODE_MINLOT);
   if (lot < myMinLot){ 
      lot = myMinLot;
   }
   if (lot > myMaxLot){ 
      lot = myMaxLot;
   }

   return lot;
}

double getFixLot(double stopInPips){
   
   double lot = 0.01;
   
   double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
   if(Point == 0.001 || Point == 0.00001){ 
      tickValue *= 10;
   }
   
   double lotSize = MarketInfo(Symbol(),MODE_LOTSIZE);
   
   double LotStep = MarketInfo(_Symbol, MODE_LOTSTEP);
   int    Decimals = 0;
   if(LotStep == 0.1){
      Decimals = 1;
   }
   else if(LotStep == 0.01){
      Decimals = 2;
   }
   
   double accountValue = initialDeposit;
   double valuePerPip = (initialDeposit*(RiskPercent/100))/stopInPips;
   lot = valuePerPip/tickValue;
   lot = StrToDouble(DoubleToStr(lot,Decimals));
   
   double myMaxLot = MarketInfo(_Symbol, MODE_MAXLOT);
   double myMinLot = MarketInfo(_Symbol, MODE_MINLOT);
   if (lot < myMinLot){ 
      lot = myMinLot;
   }
   if (lot > myMaxLot){ 
      lot = myMaxLot;
   }

   return lot;
}


//ATR
void updateValues(){
   double point = Point
   if(Point == 0.001 || Point == 0.00001){ 
      point *= 10;
   }
   myATR = iATR(NULL, 0, ATRPeriod, 1)/point;
   takeProfit = myATR * TakeProfitPercent/100.0;
   stopLoss = myATR * StopLossPercent/100.0;    
}

double ATRDistanceToBaseline(int order){
   if (order == LONG) return (Ask - getBaselineValue()) / (Point/10);
   else if (order == SHORT) return (getBaselineValue() - Bid) / (Point/10);
}


//INDICATORS
int getConfirmationCondition(){}

int getConfirmationFirstCross(){}

int getConfirmationSevenCandlesPriorCondition(){}

int getVolumeCondition(){}

int getBaselineCondition(){}

int getBaselineValue(){}

int getBaselineFirstCross(){}


//SIGNAL
int checkForSignal(){
   if((getConfirmationFirstCross() == LONG) || (getConfirmationFirstCross() == SHORT)){
      getConfirmationEntry()
   }
   else if ((getBaselineFirstCross() == LONG) || (getBaselineFirstCross() == SHORT)){
      getBaselineEntry()
   }
   else return FLAT;
} 

int getConfirmationEntry(){
   updateValues()
   if((getVolumeCondition == LONG) && (getBaselineCondition == LONG) && (ATRDistanceToBaseline(LONG) <= myATR)) return LONG;
   else if((getVolumeCondition == SHORT) && (getBaselineCondition == SHORT) && (ATRDistanceToBaseline(SHORT) <= myATR)) return SHORT;
   else return FLAT;
}

int getBaselineEntry(){
   updateValues()
   if(getConfirmationCondition == SHORT &&
      getVolumeCondition == SHORT &&
      getConfirmationSevenCandlesPriorCondition == LONG &&
      ATRDistanceToBaseline(SHORT) <= myATR)
      return SHORT;
   else if( getConfirmationCondition == LONG &&
            getVolumeCondition == LONG &&
            getConfirmationSevenCandlesPriorCondition == SHORT &&
            ATRDistanceToBaseline(LONG) <= myATR)
            return LONG; 
   else return FLAT;
}