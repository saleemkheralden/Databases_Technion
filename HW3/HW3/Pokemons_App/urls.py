from django.urls import path
from Pokemons_App import views

urlpatterns = [
    path('', views.index, name='index'),
    path('queryResults', views.queryResults, name='queryResults'),
    path('addPokemon', views.addPokemon, name='addPokemon'),
]
