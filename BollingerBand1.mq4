//+------------------------------------------------------------------+
//|                                                BollingerBand.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int BBPeriod = 20;
input double BBDeviation = 2;
input double Lots = 1.0;

int Ticket = 0;

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
      double BBMain1  = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_MAIN, 1);
      double BBUpper1 = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, 1);
      double BBLower1 = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, 1);
      
      double BBMain2  = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_MAIN, 2);
      double BBUpper2 = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, 2);
      double BBLower2 = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, 2);
      
      int pos = 0;//ポジションの管理 0→ノーポジ、1→ポジあり
      
      if(OrderSelect(Ticket, SELECT_BY_TICKET) && OrderCloseTime() == 0)
      {
         if(OrderType() == OP_BUY) pos = 1;
         if(OrderType() == OP_SELL) pos = -1;
      }
      
      bool ret;
      
      //売りポジションの決済シグナルがあれば決済注文を行う
      if(pos < 0 && Close[2] >= BBMain2 && Close[1] < BBMain1)//決済する条件
      {
         ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), 0);
         if(ret) pos = 0;//決済成功すればポジションなしにする
      }
      
      
      //買いポジションの決済シグナルがあれば決済注文を行う
      if(pos > 0 && Close[2] <= BBMain2 && Close[1] > BBMain1)
      {
         ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), 0);
         if(ret) pos = 0;
      }
      
      //買うときの条件
      if(Close[2] >= BBLower2 && Close[1] < BBLower1)
      {   
         //ポジションがなければ買い注文を行う
         if(pos == 0)Ticket = OrderSend(_Symbol, OP_BUY, Lots, Ask, 0, 0, 0);
      }
      
      
      //売るときの条件
      if(Close[2] <= BBUpper2 && Close[1] > BBUpper1)
      {
         //ポジションがなければ売り注文を行う
         if(pos == 0) Ticket = OrderSend(_Symbol, OP_SELL, Lots, Bid, 0, 0, 0);
      }
  }
//+------------------------------------------------------------------+