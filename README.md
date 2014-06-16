Weather
=======

Задание: https://gist.github.com/beshkenadze/9834122

Необходимо создать погодное приложение. Приложение должно иметь минимум 2 встроенных города (Санкт-Петербург, Москва), 
пользователь может добавить свой город. Приложение должно выводить города с указание температуры, приложение должно уметь 
показывать более подробную информацию по городу и уметь показывать прогноз погоды (3 или 7 дней). 
http://developer.yahoo.com/weather/, или на http://openweathermap.org/API, или любой другой на выбор.

Для работы с базой данных выбрана Core Data и NSFetchedResultsController для отображения данных.
В БД одна таблица городов со всей текущей информацией по городу. Прогноз погоды в БД не сохраняетя, 
а запрашивается каждый раз при выборе конкретного города. 
Выбран сервис: http://openweathermap.org/API.
Для работы с сервисом: NSURLSession.
Формат данных: JSON.