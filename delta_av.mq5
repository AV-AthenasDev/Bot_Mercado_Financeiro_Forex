//+------------------------------------------------------------------+
//|                                                      Delta_AV.mq5 |
//|                                      Copyright 2024, Aldair VL   |
//|                                       https://www.mql5.com       |
//+------------------------------------------------------------------+
#property copyright "ALDAIR VL"
#property link      "https://www.mql5.com"
#property version   "1.06"
//+------------------------------------------------------------------+
//| Indicator settings                                               |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 3

// Definindo os gráficos
#property indicator_label1 "Positive Delta"
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 MediumSpringGreen
#property indicator_width1 2

#property indicator_label2 "Negative Delta"
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_color2 OrangeRed
#property indicator_width2 2

#property indicator_label3 "Zero Line"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Gray
#property indicator_width3 1

// Buffers for storing delta values
double DeltaBufferPos[];
double DeltaBufferNeg[];
double ZeroLine[];

// Input variables for customizing chart appearance
input color ColorPos = MediumSpringGreen;       // Color for positive values
input color ColorNeg = OrangeRed;        // Color for negative values
input color ColorZero = Gray;      // Color for zero line
input int WidthPos = 2;               // Width for positive values
input int WidthNeg = 2;               // Width for negative values
input int WidthZero = 1;              // Width for zero line
input int ChartTypePos = DRAW_HISTOGRAM;  // Type of chart for positive bars
input int ChartTypeNeg = DRAW_HISTOGRAM;  // Type of chart for negative bars
input int ChartTypeZero = DRAW_LINE;      // Type of chart for zero line

// Variáveis intermediárias para armazenar as cores carregadas
color LoadedColorPos;
color LoadedColorNeg;
color LoadedColorZero;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Load saved colors
   LoadColors();

   // Indicator buffer mapping
   SetIndexBuffer(0, DeltaBufferPos, INDICATOR_DATA);
   SetIndexBuffer(1, DeltaBufferNeg, INDICATOR_DATA);
   SetIndexBuffer(2, ZeroLine, INDICATOR_DATA);

   // Indicator buffer properties for positive values
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, WidthPos);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, ChartTypePos);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, LoadedColorPos);

   // Indicator buffer properties for negative values
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, WidthNeg);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, ChartTypeNeg);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, LoadedColorNeg);

   // Indicator buffer properties for zero line
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, WidthZero);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, ChartTypeZero);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, LoadedColorZero);

   // Initialize zero line with zeros
   ArrayInitialize(ZeroLine, 0.0);

   // Name of the indicator
   IndicatorSetString(INDICATOR_SHORTNAME, "Delta Volume");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Save colors to global variables                                  |
//+------------------------------------------------------------------+
void SaveColors()
  {
   GlobalVariableSet("DeltaVolume_ColorPos", ColorPos);
   GlobalVariableSet("DeltaVolume_ColorNeg", ColorNeg);
   GlobalVariableSet("DeltaVolume_ColorZero", ColorZero);
  }

//+------------------------------------------------------------------+
//| Load colors from global variables                                |
//+------------------------------------------------------------------+
void LoadColors()
  {
   if (GlobalVariableCheck("DeltaVolume_ColorPos"))
      LoadedColorPos = (color)GlobalVariableGet("DeltaVolume_ColorPos");
   else
      LoadedColorPos = ColorPos;

   if (GlobalVariableCheck("DeltaVolume_ColorNeg"))
      LoadedColorNeg = (color)GlobalVariableGet("DeltaVolume_ColorNeg");
   else
      LoadedColorNeg = ColorNeg;

   if (GlobalVariableCheck("DeltaVolume_ColorZero"))
      LoadedColorZero = (color)GlobalVariableGet("DeltaVolume_ColorZero");
   else
      LoadedColorZero = ColorZero;
  }

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   // Determine starting point
   int start = prev_calculated;
   if (start == 0)
   {
      start = 1;
   }
   
   // Ensure buffers are cleared before calculation
   ArraySetAsSeries(DeltaBufferPos, true);
   ArraySetAsSeries(DeltaBufferNeg, true);
   ArraySetAsSeries(ZeroLine, true);

   for (int i = start; i < rates_total; i++)
     {
      // Calculating delta
      if(close[i] > open[i])
        {
         DeltaBufferPos[i] = (double)tick_volume[i];   // Buying volume
         DeltaBufferNeg[i] = 0.0;                      // Clear negative buffer
        }
      else if(close[i] < open[i])
        {
         DeltaBufferNeg[i] = -(double)tick_volume[i];  // Selling volume
         DeltaBufferPos[i] = 0.0;                      // Clear positive buffer
        }
      else
        {
         DeltaBufferPos[i] = 0.0;                      // Clear positive buffer
         DeltaBufferNeg[i] = 0.0;                      // Clear negative buffer
        }
     }

   // Save colors after calculation
   SaveColors();

   return(rates_total);
  }
//+------------------------------------------------------------------+
