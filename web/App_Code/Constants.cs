using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for Constants
/// </summary>
public static class Constants
{
    public enum ActionType
    {
        SALES=1,
        PURCHASE=2,
        SALES_RETURN=3,
        PURCHASE_RETURN=4,
        WITHDRAWAL=5,
        DEPOSIT=6,
        DEBIT_NOTE=7,
        STOCK_TRANSFER = 8,
        INCOME = 9,
        EXPENSE = 10,
        MANUAL_ITEM_EDIT = 11
    }

    public enum PartnerType
    {
        CUSTOMER = 1,
        VENDOR = 2,
        COMMONUSER=3
    }
    public enum PurchaseStatus
    {
        Complete = 1,
        Cancel = 0
    }
}