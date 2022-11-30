from django.urls import path
from Stocks_App import views

urlpatterns = [
    path('', views.index, name='index'),
    path('queryResults', views.queryResults, name='query'),
    path('addTransaction', views.addTransaction, name='addTransaction'),
    path('buyStocks', views.buyStocks, name='buyStocks'),

]
