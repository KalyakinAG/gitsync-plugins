
#Использовать logos

Перем ВерсияПлагина;
Перем Лог;
Перем КомандыПлагина;
Перем МассивНомеровВерсий;
Перем Лимит;
Перем Обработчик;
Перем НачальнаяВерсия;
Перем КонечнаяВерсия;

#Область Интерфейс_плагина

// Возвращает версию плагина
//
//  Возвращаемое значение:
//   Строка - текущая версия плагина
//
Функция Версия() Экспорт
	Возврат "1.3.0";
КонецФункции

// Возвращает приоритет выполнения плагина
//
//  Возвращаемое значение:
//   Число - приоритет выполнения плагина
//
Функция Приоритет() Экспорт
	Возврат 0;
КонецФункции

// Возвращает описание плагина
//
//  Возвращаемое значение:
//   Строка - описание функциональности плагина
//
Функция Описание() Экспорт
	Возврат "Плагин добавляет возможность ограничения на минимальный, максимальный номер версии хранилища, а так же на лимит на количество выгружаемых версий за один запуск";
КонецФункции

// Возвращает подробную справку к плагину 
//
//  Возвращаемое значение:
//   Строка - подробная справка для плагина
//
Функция Справка() Экспорт
	Возврат "Справка плагина";
КонецФункции

// Возвращает имя плагина
//
//  Возвращаемое значение:
//   Строка - имя плагина при подключении
//
Функция Имя() Экспорт
	Возврат "limit";
КонецФункции 

// Возвращает имя лога плагина
//
//  Возвращаемое значение:
//   Строка - имя лога плагина
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.gitsync.plugins.limit";
КонецФункции

#КонецОбласти

#Область Подписки_на_события

Процедура ПриАктивизации(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;

КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации) Экспорт

	Лог.Отладка("Ищу команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);

	КлассРеализации.Опция("l limit", 0, СтрШаблон("[*limit] выгрузить не более <Количества> версий от текущей выгруженной"))
						.ТЧисло()
						.ВОкружении("GITSYNC_LIMIT");
	КлассРеализации.Опция("minversion", 0, СтрШаблон("[*limit] <номер> минимальной версии для выгрузки"))
						.ТЧисло();
	КлассРеализации.Опция("maxversion", 0, СтрШаблон("[*limit] <номер> максимальной версии для выгрузки"))
						.ТЧисло();

КонецПроцедуры

Процедура ПриПолученииПараметров(ПараметрыКоманды) Экспорт

	Лимит = ПараметрыКоманды.Параметр("limit", 0);
	НачальнаяВерсия = ПараметрыКоманды.Параметр("minversion", 0);
	КонечнаяВерсия = ПараметрыКоманды.Параметр("maxversion", 0);

	Если Лимит > 0  Тогда
		Лог.Информация("Установлен лимит <%1> для количества версий, при выгрузке", Лимит);
	КонецЕсли;

	Если НачальнаяВерсия > 0 Тогда
		Лог.Информация("Установлена начальная версия <%1> при выгрузке версий", НачальнаяВерсия);
	КонецЕсли;
	Если КонечнаяВерсия > 0  Тогда
		Лог.Информация("Установлена конечная версия <%1> при выгрузке версий", КонечнаяВерсия);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередНачаломЦиклаОбработкиВерсий(ТаблицаИсторииХранилища, ТекущаяВерсия, СледующаяВерсия, МаксимальнаяВерсияДляРазбора) Экспорт

	Если НачальнаяВерсия > 0 Тогда
		СледующаяВерсия = Макс(НачальнаяВерсия, СледующаяВерсия);
	КонецЕсли;

	Если Лимит > 0 Тогда

		СтрокаТекущейВерсии = ТаблицаИсторииХранилища.Найти(ТекущаяВерсия, "НомерВерсии");
		ИндексСтрокиТекущейВерсии = ТаблицаИсторииХранилища.Индекс(СтрокаТекущейВерсии);
		ИндексСтрокиСОграничением = Мин(ТаблицаИсторииХранилища.Количество() - 1, ИндексСтрокиТекущейВерсии + Лимит);
		НомерВерсииСогласноЛимита = ТаблицаИсторииХранилища[ИндексСтрокиСОграничением].НомерВерсии;

		Если КонечнаяВерсия = 0 Тогда
			КонечнаяВерсия = НомерВерсииСогласноЛимита;
		Иначе
			КонечнаяВерсия = ?(КонечнаяВерсия >= НомерВерсииСогласноЛимита, КонечнаяВерсия, НомерВерсииСогласноЛимита);
		КонецЕсли;

	КонецЕсли;

	МаксимальнаяВерсияДляРазбора = ОпределитьМаксимальнуюВерсиюСУчетомОграниченияСверху(ТаблицаИсторииХранилища, ТекущаяВерсия, КонечнаяВерсия);

КонецПроцедуры

#КонецОбласти

Функция ОпределитьМаксимальнуюВерсиюСУчетомОграниченияСверху(Знач ТаблицаИсторииХранилища, Знач ТекущаяВерсия, Знач МаксимальнаяВерсия)

	МаксимальнаяВерсияДляРазбора = 0;
	ЧислоВерсийПлюс = 0;

	Если МаксимальнаяВерсия <> 0 Тогда
		Попытка
			МаксимальнаяВерсия = Число(МаксимальнаяВерсия);
		Исключение
			МаксимальнаяВерсия = 0;
		КонецПопытки;
	КонецЕсли;

	МаксВерсияВХранилище = ОпределитьМаксимальнуюВерсиюВХранилище(ТаблицаИсторииХранилища);

	Если МаксимальнаяВерсия > 0 Тогда
		МаксимальнаяВерсияДляРазбора = Мин(МаксВерсияВХранилище, МаксимальнаяВерсия) ;
	Иначе
		МаксимальнаяВерсияДляРазбора = МаксВерсияВХранилище;
	КонецЕсли;

	Возврат МаксимальнаяВерсияДляРазбора;

КонецФункции

Функция ОпределитьМаксимальнуюВерсиюВХранилище(Знач ТаблицаИсторииХранилища)

	Если ТаблицаИсторииХранилища.Количество() = 0 Тогда
		Возврат 0;
	КонецЕсли;

	МаксимальнаяВерсия = Число(ТаблицаИсторииХранилища[0].НомерВерсии);
	Для Сч = 1 По ТаблицаИсторииХранилища.Количество()-1 Цикл
		ЧислоВерсии = Число(ТаблицаИсторииХранилища[Сч].НомерВерсии);
		Если ЧислоВерсии > МаксимальнаяВерсия Тогда
			МаксимальнаяВерсия = ЧислоВерсии;
		КонецЕсли;
	КонецЦикла;

	Возврат МаксимальнаяВерсия;

КонецФункции

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	Лимит = 0;
	КонечнаяВерсия = 0;
	НачальнаяВерсия = 0;
	
КонецПроцедуры

Инициализация();


