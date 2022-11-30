import datetime
from django.shortcuts import render, redirect
# from .models import St
from django.db import connection

first = True

def dictfietchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def execSQL(sql):
    with connection.cursor() as cursor:
        cursor.execute(sql)
        try:
            sql_res = dictfietchall(cursor)
            return sql_res
        except:
            return None


def query1():
    return execSQL('''
    SELECT   Name,TotalSum
    FROM Investor
    INNER JOIN
        (SELECT ID,Round(Sum(Price*BQuantity),3,0) as TotalSum
        FROM
            (SELECT Stock.tDate as tDate,ID,Stock.Symbol as symbol,BQuantity,Price
                FROM Stock
                INNER JOIN
                    (SELECT tDate,Buying.ID as ID,Symbol,BQuantity
                    FROM IDS
                        INNER JOIN Buying
                        ON Buying.ID=IDS.ID)B
            ON B.Symbol=Stock.Symbol and B.tDate=Stock.tDate)C
        GROUP BY ID)D
    ON D.ID=Investor.ID
    ORDER BY TotalSum desc
    ''')


def query2():
    return execSQL('''
    SELECT Symbol,Name,Quantity
    FROM (SELECT *
        FROM NOT_MAX
            EXCEPT (SELECT O1.ID AS ID,O1.Quantity AS Quntity ,O1.symbol AS Symbol
                          FROM NOT_MAX O1,NOT_MAX O2
                          Where O1.Quantity<O2.Quantity and O1.ID!=O2.ID and O1.symbol=O2.symbol))B
    INNER JOIN Investor
    ON Investor.ID=B.ID
    ORDER BY Symbol
    ''')


def query3():
    return execSQL('''
    SELECT G.tDate as Date ,G.Symbol As Symbol ,Name
        FROM Investor INNER JOIN(SELECT ID,Buying.Symbol As Symbol,Companys.tDAte As tDate
    FROM Companys INNER JOIN Buying
    ON (Companys.Symbol=Buying.Symbol and Buying.tDate=Companys.tDAte))G
    ON Investor.ID=G.ID
    ORDER BY Date,Symbol
    ''')


# Create your views here.
def index(request):
    return render(request, 'index.html')


def queryResults(request):

    data = {'query1': query1(),
            'query2': query2(),
            'query3': query3()}

    return render(request, 'queryResults.html', data)


def processTransaction(_id, transactionSum):
    todaysDate = datetime.datetime.now().date().__str__()
    available = float(execSQL(f"SELECT AvailableCash FROM Investor WHERE ID='{_id}'")[0]['AvailableCash'])
    execSQL(f"UPDATE Investor SET AvailableCash={available + transactionSum} WHERE ID='{_id}'")

    if len(execSQL(f"SELECT * FROM Transactions WHERE tDate='{todaysDate}' AND ID='{_id}'")) == 0:
        execSQL(f"INSERT INTO Transactions (tDate, ID, TQuantity) VALUES ('{todaysDate}', '{_id}', {transactionSum})")
    else:
        execSQL(f"UPDATE Transactions SET TQuantity={transactionSum} WHERE tDate='{todaysDate}' AND ID='{_id}'")


def addTransaction(request):
    if request.method == 'POST':
        _id = request.POST['transactionId']
        transactionSum = float(request.POST['transactionSum'])
        request.session['reason'] = list()

        if len(execSQL(f"SELECT ID FROM Investor WHERE ID='{_id}'")) == 0:
            request.session['flag'] = False
            request.session['reason'].append('ID is incorrect.')
        else:
            request.session['flag'] = True
            print(_id, transactionSum)
            processTransaction(_id, transactionSum)

        return redirect('addTransaction')

    data = {'transactions': execSQL('SELECT TOP 10 * FROM Transactions ORDER BY tDate DESC, ID DESC'),
            'flag': request.session.get('flag')}

    if not data['flag']:
        data['reason'] = request.session.get('reason')

    request.session['flag'] = None
    request.session['reason'] = None
    return render(request, 'addTransaction.html', data)


def get10Stocks():
    return execSQL('''
        SELECT TOP 10 Buying.tDate Date, Buying.ID InvestorID,  Buying.Symbol Company, ROUND(BQuantity * Price, 3) Payed
        FROM Buying
        INNER JOIN Stock
        ON Buying.Symbol = Stock.Symbol AND Buying.tDate = Stock.tDate ORDER BY Payed DESC, InvestorID DESC
        ''')


def processRequest(buyData):
    todaysDate = datetime.datetime.now().date().__str__()
    if len(execSQL(f"SELECT * FROM Stock WHERE Symbol='{buyData['company']}' AND tDate='{todaysDate}'")) == 0:
        execSQL(f"INSERT INTO Stock (Symbol, tDate, Price) "
                f"VALUES ('{buyData['company']}', '{todaysDate}' , {buyData['latestPrice']})")

    execSQL(f"UPDATE Investor SET AvailableCash={buyData['available'] - buyData['total']} WHERE ID={buyData['id']}")

    execSQL(f"INSERT INTO Buying (tDate, ID, Symbol, BQuantity) "
            f"VALUES ('{todaysDate}', '{buyData['id']}', '{buyData['company']}', {buyData['quantity']})")


def buyStocks(request):
    if request.method == 'POST':
        request.session['reason'] = list()
        _id = request.POST['id']
        company = request.POST['company']

        todaysdate = datetime.datetime.now().date().__str__()

        idFlag = True
        companyFlag = True

        if len(execSQL(f"SELECT Symbol FROM Company WHERE Symbol='{company}' ")) == 0:
            request.session['flag'] = False
            request.session['reason'].append('Company symbol is incorrect.')
            companyFlag = False
        if len(execSQL(f"SELECT ID FROM Investor WHERE ID='{_id}'")) == 0:
            request.session['flag'] = False
            request.session['reason'].append('ID is incorrect.')
            idFlag = False

        if companyFlag:
            latestPrice = float(
                execSQL(f"SELECT TOP 1 Price FROM Stock WHERE Symbol='{company}' ORDER BY tDate DESC")[0]['Price'])
        else:
            latestPrice = 0

        quantity = int(request.POST['quantity'])

        if idFlag:
            available = execSQL(f"SELECT AvailableCash FROM Investor WHERE ID='{_id}'")[0]['AvailableCash']
        else:
            available = 0

        buyData = {'id': _id,
                   'company': company,
                   'quantity': quantity,
                   'latestPrice': latestPrice,
                   'available': available,
                   'total': quantity * latestPrice}

        # print(buyData)
        # print(datetime.datetime.now())

        request.session['buyData'] = buyData

        if 0 < available <= latestPrice * quantity and latestPrice > 0:
            request.session['reason'].append('Available cash is less than the requested total.')
            request.session['flag'] = False
        elif 0 < available and 0 < latestPrice:
            if len(execSQL(f"SELECT * FROM Buying WHERE ID='{_id}' AND Symbol='{company}' AND tDate='{todaysdate}'")) > 0:
                request.session['reason'].append("Can't buy multiple stocks for the same company in the same day.")
                request.session['flag'] = False
            else:
                request.session['flag'] = True
                processRequest(buyData)

        return redirect('buyStocks')

    data = {'stocks': get10Stocks(),
            'buyData': request.session.get('buyData')}
    if request.session.get('flag'):
        data['flag'] = True
    elif request.session.get('flag') is False:
        data['flag'] = False
        data['reason'] = request.session.get('reason')

    request.session['flag'] = None
    request.session['buyData'] = None
    request.session['reason'] = None

    # print(data)

    return render(request, 'buyStocks.html', data)

