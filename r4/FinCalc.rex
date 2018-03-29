/* FinCalc.rex
 this program computes financial ratios

 this program receives input FinCalc.TopHat

 input values are received from TopHat.EXE via the registry

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\FinCalc[Request]

 this program shows its output using FinCalcOut.TopHat

 output values are passed to TopHat.EXE via the registry

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\FinCalcOut[Request]
*/

tab = d2c( 9 )

/* get FinCalc.TopHat request */

request = value( 'HKLM\Software\Kilowatt Software\R4\FinCalc[Request]', , 'Registry' )

/* parse tab delimited request fields */

parse var request ,
  Company (tab) ,
  Sales (tab) ,
  CostOfGoods (tab) ,
  NetIncome (tab) ,
  Cash (tab) ,
  AccountsReceivable (tab) ,
  AccountsReceivablePrior (tab) ,
  Inventory (tab) ,
  InventoryPrior (tab) ,
  OtherCurrentAssets (tab) ,
  PropertyEquipment (tab) ,
  AccumulatedDepreciation (tab) ,
  OtherAssets (tab) ,
  TotalAssetsPrior (tab) ,
  CurrentLiabilities (tab) ,
  LongTermDebt (tab) ,
  OtherLiabilities (tab) ,
  PreferredStock (tab) ,
  CommonStock (tab) ,
  RetainedEarnings (tab) ,
  StockholdersEquity (tab) ,
  StockValue (tab) ,
  SharesOutstanding (tab) ,
  PreferredDividends (tab)

/* perform computations */

CurrentCapital = Cash + AccountsReceivable + Inventory + OtherCurrentAssets

WorkingCapital = CurrentCapital - CurrentLiabilities

CurrentRatio = Round( CurrentCapital / CurrentLiabilities, 2 )

AcidTestRatio = Round( ( Cash + AccountsReceivable ) / CurrentLiabilities, 2 )

AccountsReceivableTurnover = Round( Sales / ( ( AccountsReceivable + AccountsReceivablePrior ) / 2 ), 1 )

DaysSalesInAccountsReceivable = Round( AccountsReceivable / ( Sales / 300 ) )

InventoryTurnover = Round( CostOfGoods / ( ( Inventory + InventoryPrior ) / 2 ), 1 )

DaysSalesInInventory = Round( Inventory / ( CostOfGoods / 300 ) )

GrossProfitRate = Round( ( Sales - CostOfGoods ) / Sales * 1000 ) / 10

NetProfitToAssets = ,
  Round( ( NetIncome / ,
  	( ( Cash + AccountsReceivable + Inventory + OtherCurrentAssets + PropertyEquipment ,
 		 - AccumulatedDepreciation + ( OtherAssets + TotalAssetsPrior ) ) / 2 ) * 1000 ) / 10 )

NetProfitToNetWorth = ,
  Round( NetIncome / ( ( PreferredStock + CommonStock + RetainedEarnings + StockholdersEquity ) / 2 ) * 1000 ) / 10

NetWorthToLiabilities = ,
  Round( ( PreferredStock + CommonStock + RetainedEarnings ) / ( CurrentLiabilities + LongTermDebt +  OtherLiabilities ), 2 )

FixedAssetsToLongTermDebt = ,
  Round( ( PropertyEquipment - AccumulatedDepreciation ) / LongTermDebt, 2 )

NetWorthToFixedAssets = ,
  Round( ( PreferredStock + CommonStock + RetainedEarnings ) / ( PropertyEquipment - AccumulatedDepreciation ), 2 )

PercentOfFixedAssetsDepreciated = ,
  Round( AccumulatedDepreciation / PropertyEquipment * 100 )

BookValuePerShare = ,
  Round( ( CommonStock + RetainedEarnings ) / SharesOutstanding, 2 )

EarningsPerShare = ,
  Round( ( NetIncome - PreferredDividends ) / SharesOutstanding, 2 )

PriceEarningsRatio = ,
  Round( StockValue / EarningsPerShare, 1 )

/* prepare tab delimited FinCalcOut.TopHat response */

FinCalcOut = ,
     Company || tab ,
  || WorkingCapital || tab ,
  || CurrentRatio || tab ,
  || AcidTestRatio || tab ,
  || AccountsReceivableTurnover || tab ,
  || DaysSalesInAccountsReceivable || tab ,
  || InventoryTurnover || tab ,
  || DaysSalesInInventory || tab ,
  || GrossProfitRate || tab ,
  || NetProfitToAssets || tab ,
  || NetProfitToNetWorth || tab ,
  || NetWorthToLiabilities || tab ,
  || FixedAssetsToLongTermDebt || tab ,
  || NetWorthToFixedAssets || tab ,
  || PercentOfFixedAssetsDepreciated || tab ,
  || BookValuePerShare || tab ,
  || EarningsPerShare || tab ,
  || PriceEarningsRatio || tab

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value 'HKLM\Software\Kilowatt Software\R4\FinCalcOut[Request]', FinCalcOut, 'Registry'

trace off /* ignore error code when cancel is pressed */

'TopHat FinCalcOut.TopHat'

exit 0

Round : procedure

  if arg() = 1 then
    return trunc( arg(1) + .5 )

  return trunc( arg(1) + ( '.'copies( '0', arg( 2 ) )'5' ), arg( 2 ) )
