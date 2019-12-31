#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| External Variabes                                                |
//+------------------------------------------------------------------+
extern int fast = 12;
extern int slow = 26;

//+------------------------------------------------------------------+
//| Internal Variabes                                                |
//+------------------------------------------------------------------+
bool trading = false;
bool buying  = false;
bool selling = false;
bool error   = true;

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
{   
    buying  = false;
    trading = false;
    selling = false;
    
    for (int i = 0; i < OrdersTotal(); i++)
    {   
        error = OrderSelect(i, SELECT_BY_POS);
    
        if (OrderSymbol() == Symbol())
        {   
            if (OrderType() == OP_BUY)  buying  = true;
            if (OrderType() == OP_SELL) selling = true;

            trading = true;
            CheckAndPlaceStopLoss();
            break;
        }
    }

    OpenOrder();
    
    Comment("Trading: " + string(trading));
}

//--- Open Order
void OpenOrder()
{
    if (trading) return;
        
    const double SMA_FAST = iMA(NULL, NULL, fast, 0, MODE_SMA, PRICE_CLOSE, 0);
    const double SMA_SLOW = iMA(NULL, NULL, slow, 0, MODE_SMA, PRICE_CLOSE, 0);
    
    const double SMA_FAST_PREV = iMA(NULL, NULL, fast, 0, MODE_SMA, PRICE_CLOSE, 1);
    const double SMA_SLOW_PREV = iMA(NULL, NULL, slow, 0, MODE_SMA, PRICE_CLOSE, 1);
    
    if (SMA_FAST < SMA_SLOW && SMA_FAST_PREV > SMA_SLOW_PREV)
        error = OrderSend(NULL, OP_BUY,  0.01, Ask, 1, Bid / 2, 0, NULL, 999);
    
    if (SMA_FAST > SMA_SLOW && SMA_FAST_PREV < SMA_SLOW_PREV)
        error = OrderSend(NULL, OP_SELL, 0.01, Bid, 1, Ask * 2, 0, NULL, 999);
}

//--- Close Order
void CloseOrder()
{
}

//+------------------------------------------------------------------+
//| Stop Loss Fuction                                                |
//+------------------------------------------------------------------+
void CheckAndPlaceStopLoss()
{
    double buying_SL  = NormalizeDouble(Bid / 1.002, Digits);
    double selling_SL = NormalizeDouble(Ask * 1.002, Digits);
    
    if (buying && buying_SL > OrderStopLoss())
        error = OrderModify(OrderTicket(), 0, buying_SL, 0, 0);
        
    if (selling && selling_SL < OrderStopLoss())
        error = OrderModify(OrderTicket(), 0, selling_SL, 0, 0);
}

//+------------------------------------------------------------------+
//| Error Check                                                      |
//+------------------------------------------------------------------+
void ErrorCheck()
{
    if (error == false) printf("%i", GetLastError());
}
