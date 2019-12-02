#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| External Variabes                                                |
//+------------------------------------------------------------------+
extern int    period    = 20;
extern double deviation = 2;
//+------------------------------------------------------------------+
//| Internal Variabes                                                |
//+------------------------------------------------------------------+
bool trading = false;
bool buying  = false;
bool selling = false;
bool error   = true;
double const MINSTOP = MarketInfo(NULL, MODE_STOPLEVEL) * Point;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{   buying  = false;
    trading = false;
    selling = false;
    
    for (int i = 0; i < OrdersTotal(); i++)
    {   error = OrderSelect(i, SELECT_BY_POS);
        ErrorCheck();
    
        if (OrderSymbol() == Symbol())
        {   if (OrderType() == OP_BUY)  buying  = true;
            if (OrderType() == OP_SELL) selling = true;

            trading = true;
            //CheckAndPlaceStopLoss();
            break;
        }
    }
    
    const double BAND_UPPER = iBands(NULL, NULL, period, deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
    const double BAND_LOWER = iBands(NULL, NULL, period, deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
    const double BAND_MAIN  = iBands(NULL, NULL, period, deviation, 0, PRICE_CLOSE, MODE_MAIN, 0);
    
    const double BAND_UPPER_PREV = iBands(NULL, NULL, period, deviation, 0, PRICE_CLOSE, MODE_UPPER, 1);
    const double BAND_LOWER_PREV = iBands(NULL, NULL, period, deviation, 0, PRICE_CLOSE, MODE_LOWER, 1);
    
    if (Ask > BAND_LOWER && Ask < BAND_LOWER_PREV && !trading) error = OrderSend(NULL, OP_BUY,  0.01, Ask, 1, Bid / 2, 0, NULL, 999);
    if (Bid < BAND_UPPER && Bid > BAND_UPPER_PREV && !trading) error = OrderSend(NULL, OP_SELL, 0.01, Bid, 1, Ask * 2, 0, NULL, 999);
    ErrorCheck();
    
    if (buying  && Bid > BAND_MAIN) error = OrderClose(OrderTicket(), OrderLots(), Bid, 1);
    if (selling && Ask < BAND_MAIN) error = OrderClose(OrderTicket(), OrderLots(), Ask, 1);
    ErrorCheck();
    
    Comment("Trading: " + string(trading));
  }
//+------------------------------------------------------------------+
//| Stop Loss Fuction                                                |
//+------------------------------------------------------------------+
void CheckAndPlaceStopLoss()
{
    double buying_SL  = NormalizeDouble(Bid / 1.005, Digits);
    double selling_SL = NormalizeDouble(Ask * 1.005, Digits);
    
    if (buying && buying_SL > OrderStopLoss())
        error = OrderModify(OrderTicket(), 0, buying_SL, 0, 0);
        
    if (selling && selling_SL < OrderStopLoss())
        error = OrderModify(OrderTicket(), 0, selling_SL, 0, 0);
        
    ErrorCheck();
}
//+------------------------------------------------------------------+
//| Error Check                                                      |
//+------------------------------------------------------------------+
void ErrorCheck()
{
    if (error == false) printf("%i", GetLastError());
}