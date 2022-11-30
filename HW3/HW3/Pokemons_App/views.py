from django.shortcuts import render, redirect
from .models import Pokemons
from django.db import connection


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


# Create your views here.
def index(request):
    return render(request, 'index.html')


def get_strongest():
    return execSQL('''SELECT Name, A.Generation
                            FROM
                        (select Generation,Max(Hp+Attack+Defense) AS Total1
                        From Pokemons
                        GROUP BY Generation ) A
                        INNER JOIN
                         (Select Name,Generation,(Hp+Attack+Defense)As Total
                                                  From (SELECT Name,Hp,Attack,Defense,Legendary,Generation
                                                            From Pokemons
                                                             Where Legendary='1') temp) B
                        ON A.Generation=B.Generation and A.Total1=B.Total
                        ORDER BY Generation''')


def get_dominant():
    return execSQL('''SELECT Name, Type
                            FROM Pokemons
                            EXCEPT
                            (SELECT A.Name, A.Type
                            FROM Pokemons A
                            INNER JOIN Pokemons B
                            ON A.Type = B.Type AND A.Name != B.Name
                                AND (A.Attack <= B.Attack OR A.Defense <= B.Defense OR A.HP <= B.HP)) ''')


def get_pokemonsThreshold(atk, count):
    return execSQL(f'''SELECT E.Type
                        FROM (Select Type ,count(A.Name)As number
                                From (SELECT DISTINCT Name, Type
                                        FROM Pokemons
                                        Where Attack>{atk}) A
                            GROUP BY Type)E
                        Where Number>{count}
                        ORDER BY Type
                ''')


def max_avg():
    return execSQL('''
    SELECT Type, CAST(ROUND(SUM(Balance) / (1.0 * COUNT(Name)), 2) AS decimal(16, 2)) AVG
FROM (SELECT Name, Type, ABS(Attack - Defense) Balance
    FROM Pokemons) innerA
GROUP BY Type
EXCEPT
SELECT DISTINCT A.Type, A.AVG
FROM
(SELECT Type, CAST(ROUND(SUM(Balance) / (1.0 * COUNT(Name)), 2) AS decimal(16, 2)) AVG
FROM (SELECT Name, Type, ABS(Attack - Defense) Balance
    FROM Pokemons) innerA
GROUP BY Type) A
INNER JOIN
(SELECT Type, CAST(ROUND(SUM(Balance) / (1.0 * COUNT(Name)), 2) AS decimal(16, 2)) AVG
FROM (SELECT Name, Type, ABS(Attack - Defense) Balance
    FROM Pokemons) innerB
GROUP BY Type) B
ON A.AVG < B.AVG''')


def queryResults(request):
    strongest = get_strongest()
    dominant = get_dominant()
    max_average = max_avg()

    data = {'strongest': strongest,
            'dominant': dominant,
            'max_average': max_average}

    if request.method == 'POST':
        atkThresh = request.POST['attackThreshold']
        pokCount = request.POST['pokemonCount']
        request.COOKIES['attackThreshold'] = atkThresh
        request.COOKIES['pokemonCount'] = pokCount
        request.session['data'] = get_pokemonsThreshold(atkThresh, pokCount)
        return redirect('queryResults')

    data['thresh'] = request.session.get('data')
    request.session['data'] = None
    return render(request, 'queryResults.html', data)


def insertPokemon(name, _type, gen, legend, hp, atk, defense):
    try:
        execSQL(f'''
                INSERT INTO Pokemons (Name, Type, Generation, Legendary, HP, Attack, Defense) 
                VALUES ('{name}', '{_type}', {int(gen)}, '{legend}', {int(hp)}, {int(atk)}, {int(defense)})
            ''')
        return '1'
    except:
        return '-1'


def addPokemon(request):

    if request.method == 'POST':
        name = request.POST['pokemonName']
        _type = request.POST['pokemonType']
        gen = request.POST['pokemonGeneration']
        try:
            legend = '1' if request.POST['pokemonLegendary'] == 'on' else '0'
        except:
            legend = '0'
        hp = request.POST['pokemonHP']
        atk = request.POST['pokemonAttack']
        defense = request.POST['pokemonDefense']

        request.session['add'] = insertPokemon(name, _type, gen, legend, hp, atk, defense)
        return redirect('addPokemon')

    flag = request.session.get('add')
    request.session['add'] = None
    return render(request, 'addPokemon.html', {'flag': flag})







