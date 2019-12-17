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
#define EXITLONG 3
#define EXITSHORT 4

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
double myLots;


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
//--- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false)
      return;
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
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

double getHalfFractionLots(double stopInPips){
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
   double valuePerPip = (accountValue*(RiskPercent/2/100))/stopInPips;
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

double getHalfFixLot(double stopInPips){
   
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
   double valuePerPip = (initialDeposit*(RiskPercent/2/100))/stopInPips;
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
int getConfirmationFirstCross(){}

int getBaselineFirstCross(){}

int getConfirmationCondition(){}

int getConfirmationSevenCandlesPriorCondition(){}

int getVolumeCondition(){}

int getBaselineCondition(){}

int getExitSignal(){}

double getBaselineValue(){}

//SIGNAL
int checkForSignal(){
   if((getConfirmationFirstCross() == LONG) || (getConfirmationFirstCross() == SHORT)){
      getConfirmationEntry();
   }
   else if ((getBaselineFirstCross() == LONG) || (getBaselineFirstCross() == SHORT)){
      getBaselineEntry();
   }
   else return FLAT;
} 

int getConfirmationEntry(){
   updateValues();
   if((getVolumeCondition == LONG) && (getBaselineCondition == LONG) && (ATRDistanceToBaseline(LONG) <= myATR)) return LONG;
   else if((getVolumeCondition == SHORT) && (getBaselineCondition == SHORT) && (ATRDistanceToBaseline(SHORT) <= myATR)) return SHORT;
   else return FLAT;
}

int getBaselineEntry(){
   updateValues();
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


//OPENING TRADE
void checkForOpen(){
   if(Volume[0]>1) return;
   myLots = getHalfFixLot();
   
   signal = checkForSignal();
   
   if(signal == LONG){
      openTPTrade(LONG);
      openNoTPTrade(LONG);
      return;
   }
   
   else if(signal == SHORT){
      openTPTrade(SHORT);
      openNoTPTrade(SHORT);
      return;
   }
   
   else return;
}

void openTPTrade(int signal){
   updateValues()
   if(signal == LONG){
      ticket = ticket=OrderSend(Symbol(),OP_BUY,myLots,Ask,3,Ask-stopLoss*10*Point,Ask+takeProfit*10*Point,"Backtest EA",MAGICNUM,0,Green);
      if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
      else
         Print("Error opening BUY order : ",GetLastError());
      return;
   }
   
   if(signal == SHORT){
      ticket = ticket=OrderSend(Symbol(),OP_SELL,myLots,Bid,3,Bid+stopLoss*10*Point,Bid-takeProfit*10*Point,"Backtest EA",MAGICNUM,0,Red);
      if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
      else
         Print("Error opening BUY order : ",GetLastError());
      return;         
   }
}

void openNoTPTrade(int signal){
   updateValues()
   if(signal == LONG){
      ticket = ticket=OrderSend(Symbol(),OP_BUY,myLots,Ask,3,Ask-stopLoss*10*Point,0,"Backtest EA",MAGICNUM,0,Green);
      if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
      else
         Print("Error opening BUY order : ",GetLastError());
      return;
   }
   
   if(signal == SHORT){
      ticket = ticket=OrderSend(Symbol(),OP_SELL,myLots,Bid,3,Bid+stopLoss*10*Point,0,"Backtest EA",MAGICNUM,0,Red);
      if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
      else
         Print("Error opening BUY order : ",GetLastError());
      return;         
   }  
}


//CALCULATE TRADES
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICNUM)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
  

//CLOSING TRADES
void checkForClose(){
   if(Volume[0]>1) return;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICNUM || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(getExitSignal()==EXITLONG)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(getExitSignal()==EXITSHORT)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
     }
}