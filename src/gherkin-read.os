﻿////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Объект-помощник для чтения/разбора файлов функциональностей BDD - *.feature в формате Gherkin
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать asserts
#Использовать strings

Перем Лог;

Перем СоответствиеЯзыкКлючевыеСлова;
Перем СоответствиеКлючевыеСлова;

Перем ОписанияЛексем;
Перем ВозможныеТипыШагов;
Перем ВозможныеТипыНачалаСтроки;
Перем ВозможныеКлючевыеСлова;
Перем ВозможныеКлючиПараметров;

Перем УровниЛексем;
Перем ТипыШагов;

Перем РегулярныеВыражения;

////////////////////////////////////////////////////////////////////
//{ Программный интерфейс

Функция ПрочитатьФайлСценария(ФайлСценария) Экспорт
	Лог.Отладка("Читаю сценарий "+ФайлСценария.ПолноеИмя);
	Фича = Новый ЧтениеТекста(ФайлСценария.ПолноеИмя, "UTF-8");

	СтруктураФичи = РазобратьТекстФичи(Фича);
	НайденныеЛексемы = СтруктураФичи.НайденныеЛексемы;

	Фича.Закрыть();

	Возврат СтруктураФичи;
КонецФункции

Функция ВозможныеТипыШагов() Экспорт
	Рез = Новый Структура;
	Рез.Вставить(ВозможныеКлючевыеСлова.Функциональность, ВозможныеКлючевыеСлова.Функциональность);
	Рез.Вставить(ВозможныеКлючевыеСлова.Контекст, ВозможныеКлючевыеСлова.Контекст);
	Рез.Вставить(ВозможныеКлючевыеСлова.Сценарий, ВозможныеКлючевыеСлова.Сценарий);
	Рез.Вставить(ВозможныеКлючевыеСлова.структураСценария, ВозможныеКлючевыеСлова.структураСценария);
	Рез.Вставить(ВозможныеКлючевыеСлова.Примеры, ВозможныеКлючевыеСлова.Примеры);
	Рез.Вставить("Шаг", "Шаг");
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции

Функция ВозможныеКлючевыеСлова() Экспорт
	Рез = Новый Структура;
	Рез.Вставить("Допустим", "Допустим");
	Рез.Вставить("Когда", "Когда");
	Рез.Вставить("Тогда", "Тогда");
	Рез.Вставить("Также", "Также");
	Рез.Вставить("Но", "Но");
	Рез.Вставить("Функциональность", "Функциональность");
	Рез.Вставить("Контекст", "Контекст");
	Рез.Вставить("Сценарий", "Сценарий");
	Рез.Вставить("структураСценария", "структураСценария");
	Рез.Вставить("Примеры", "Примеры");
	// Рез.Вставить("Допустим", "given");
	// Рез.Вставить("Когда", "when");
	// Рез.Вставить("Тогда", "then");
	// Рез.Вставить("Также", "and");
	// Рез.Вставить("Но", "but");
	// Рез.Вставить("Функциональность", "feature");
	// Рез.Вставить("Контекст", "background");
	// Рез.Вставить("Сценарий", "scenario");
	// Рез.Вставить("структураСценария", "scenario_outline");
	// Рез.Вставить("Примеры", "examples");
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции

Функция ВозможныеКлючиПараметров() Экспорт
	Рез = Новый Структура;
	Рез.Вставить("Строка", "<ПараметрСтрока>");
	Рез.Вставить("Число", "<ПараметрЧисло>");
	Рез.Вставить("Дата", "<ПараметрДата>");
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции

Функция ТекстИсключенияДляЕщеНеРеализованногоШага() Экспорт
	Возврат "Не реализовано.";
КонецФункции

Функция ИмяЛога() Экспорт
	Возврат "oscript.app.gherkin-read";
КонецФункции

//}

////////////////////////////////////////////////////////////////////
//{ Реализация

Функция РазобратьТекстФичи(Знач Фича)

	НайденныеЛексемы = Новый Массив;
	ПредыдущиеПараметрыЛексемы = Неопределено;

	Пока Истина Цикл
		ОчереднаяСтрока = ПолучитьОчереднуюСтрокуСценария(Фича);
		Если ОчереднаяСтрока = Неопределено Тогда
			Прервать;
		КонецЕсли;

		ПервыйСимвол = Лев(ОчереднаяСтрока, 1);
		Если ПервыйСимвол = ВозможныеТипыНачалаСтроки.Комментарий Тогда
			Лог.Отладка("	Первый символ строки - это комментарий.");
			НовыйЯзык = ПолучитьЯзыкФичи(ОчереднаяСтрока);
			Если ЗначениеЗаполнено(НовыйЯзык) Тогда
				Язык = НовыйЯзык;
				СоответствиеКлючевыеСлова = СоответствиеЯзыкКлючевыеСлова.Получить(Язык);
				Лог.Отладка("	Получили язык фичи "+Язык);
			Иначе
				Лог.Отладка("		Пропускаю строку");
			КонецЕсли;
			Продолжить;

		ИначеЕсли ПервыйСимвол = ВозможныеТипыНачалаСтроки.Метка Тогда
			Лог.Отладка("	Первый символ строки - это метка. Пропускаю строку");
			Продолжить;

		ИначеЕсли ПервыйСимвол = ВозможныеТипыНачалаСтроки.Пример Тогда
			ВызватьИсключение "Обработка примеров пока не реализована";
		КонецЕсли;

		Ожидаем.Что(Язык, "Ожидали, что найдем язык будет найден "+Язык+", но не нашли").Заполнено();

		ПараметрыЛексемы = НайтиЛексему(ОчереднаяСтрока);
		Если ЗначениеЗаполнено(ПараметрыЛексемы) Тогда
			ПредыдущиеПараметрыЛексемы = ПараметрыЛексемы;
			НайденныеЛексемы.Добавить(ПараметрыЛексемы);
		Иначе
			ПредыдущиеПараметрыЛексемы.ПраваяЧасть = ПредыдущиеПараметрыЛексемы.ПраваяЧасть + Символы.ПС + ОчереднаяСтрока;
		КонецЕсли;
	КонецЦикла;

	Лог.Отладка("Нашли лексем "+НайденныеЛексемы.Количество());
	Ожидаем.Что(НайденныеЛексемы.Количество(), "Ожидали, что заданы функциональность и хотя бы один сценарий, а их нет").БольшеИлиРавно(2);

	ДеревоФич = ПолучитьДеревоФич(НайденныеЛексемы);
	Ожидаем.Что(ДеревоФич.Строки.Количество(), "Ожидали, что заданы функциональность, а их не удалось найти в файле").Равно(1);

	РезультатыРазбора = Новый Структура;
	РезультатыРазбора.Вставить("Язык", Язык);
	РезультатыРазбора.Вставить("НайденныеЛексемы", НайденныеЛексемы);
	РезультатыРазбора.Вставить("ДеревоФич", ДеревоФич);
	Возврат РезультатыРазбора;
КонецФункции

Функция НайтиЛексему(Знач Строка)
	Ожидаем.Что(СоответствиеКлючевыеСлова, "Ожидали, что найдем ключевые слова, но не нашли").Заполнено();

	СтрокаДляПоиска = НРег(Строка);
	Для каждого КлючЗначение Из СоответствиеКлючевыеСлова Цикл
		Лексема = КлючЗначение.Ключ;
		Позиция = Найти(СтрокаДляПоиска, Лексема);
		Если Позиция = 1 Тогда
			ДлинаЛексемы = СтрДлина(Лексема);

			ПраваяЧасть = Сред(Строка, ДлинаЛексемы + 1);
			Символ = Лев(ПраваяЧасть, 1);
			Если (Символ=" ") или (Символ=":") или (Символ=",") Тогда
			Иначе
				//ЛОг.Отладка("Пропускаю лексему <"+Лексема+">, т.к. следующий символ <"+Символ+">");
				Продолжить;
			КонецЕсли;
			ПраваяЧасть = СокрЛП(ПраваяЧасть);
			Символ = Лев(ПраваяЧасть, 1);
			Если (Символ=":") или (Символ=",") Тогда
				ПраваяЧасть = СокрЛП(Сред(ПраваяЧасть, 2));
			КонецЕсли;

			Рез = Новый Структура;
			Рез.Вставить("Лексема", КлючЗначение.Значение);

			Рез.Вставить("ПраваяЧасть", ПраваяЧасть);
			лог.Отладка("Нашел лексему <"+Рез.Лексема+">, правая часть <"+ПраваяЧасть+">");
			Возврат Рез;
		КонецЕсли;
	КонецЦикла;
	Возврат Неопределено;
КонецФункции

Функция ПолучитьОчереднуюСтрокуСценария(Знач Фича)
	Рез = "";
	Пока Истина Цикл
		ОчереднаяСтрока = Фича.ПрочитатьСтроку();
		Если ОчереднаяСтрока = Неопределено Тогда
			Лог.Отладка("Строки фичи закончились");
			Возврат Неопределено;
		КонецЕсли;

		Рез = СокрЛП(ОчереднаяСтрока);
		Если Не ПустаяСтрока(Рез) Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Лог.Отладка("Очередная строка фичи <"+Рез+">");
	Возврат Рез;
КонецФункции

Функция ПолучитьДеревоФич(НайденныеЛексемы)
	ДеревоФич = СоздатьДеревоФич();
	Индекс = 0;
	ОбработатьДеревоФич(НайденныеЛексемы, ДеревоФич.Строки, Индекс);

	Возврат ?(ЗначениеЗаполнено(ДеревоФич.Строки), ДеревоФич, Неопределено);
КонецФункции

Функция СоздатьДеревоФич()
	Рез = Новый ДеревоЗначений;
	Рез.Колонки.Добавить("Лексема");
	Рез.Колонки.Добавить("ТипШага");
	Рез.Колонки.Добавить("АдресШага");
	Рез.Колонки.Добавить("Тело");
	Рез.Колонки.Добавить("Параметры");
	Возврат Рез;
КонецФункции

Процедура ОбработатьДеревоФич(НайденныеЛексемы, СтрокиДерева, Индекс)
	Пока Индекс < НайденныеЛексемы.Количество() Цикл
		ПараметрыОчереднойЛексемы = НайденныеЛексемы[Индекс];
		ОчереднаяЛексема = ПараметрыОчереднойЛексемы.Лексема;
		УровеньЛексемы = УровниЛексем[ОчереднаяЛексема];
		Лог.Отладка("Получил Очередная лексема <"+ОчереднаяЛексема+">, Индекс "+Индекс+", уровень <"+УровеньЛексемы+">, тело <"+ПараметрыОчереднойЛексемы.ПраваяЧасть+">");

		ПараметрыИзСтроки = Новый Массив;
		НоваяПраваяЧасть = ИзвлечьПараметры(ПараметрыОчереднойЛексемы.ПраваяЧасть, ПараметрыИзСтроки);
		Лог.Отладка("НоваяПраваяЧасть "+НоваяПраваяЧасть);

		НоваяСтрока = ЗаполнитьУзелДереваФич(СтрокиДерева, ОчереднаяЛексема, ПараметрыОчереднойЛексемы.ПраваяЧасть); //НоваяПраваяЧасть);
		Лог.Отладка("НоваяСтрока.Лексема <"+НоваяСтрока.Лексема+">");
		НоваяСтрока.Параметры = ПараметрыИзСтроки;
		НоваяСтрока.ТипШага = НайтиТипШагаПоЛексеме(ОчереднаяЛексема);
		НоваяСтрока.АдресШага = СформироватьАдресШага(НоваяПраваяЧасть);

		СтараяСтрока = НоваяСтрока;

		Индекс = Индекс + 1;
		Если Индекс >= НайденныеЛексемы.Количество() Тогда
			Лог.Отладка("Завершаю изучать лексемы. Индекс "+Индекс);
			Прервать;
		КонецЕсли;

		НоваяЛексема = НайденныеЛексемы[Индекс].Лексема;
		НовыйУровеньЛексемы = УровниЛексем[НоваяЛексема];

		Лог.Отладка("Проверяю следующую лексему <"+НоваяЛексема+">, Индекс "+Индекс+", уровень <"+НовыйУровеньЛексемы+">");
		Если НовыйУровеньЛексемы > УровеньЛексемы Тогда // TODO здесь должны быть равнозначные узлы. Например, сценарий/примеры
			ОбработатьДеревоФич(НайденныеЛексемы, НоваяСтрока.Строки, Индекс);
		ИначеЕсли НовыйУровеньЛексемы = УровеньЛексемы Тогда
			Продолжить;
		Иначе
			Возврат;
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Функция ЗаполнитьУзелДереваФич(СтрокиДерева, Лексема, Тело)
	НоваяСтрока = СтрокиДерева.Добавить();
	ЗаполнитьЗначенияСвойств(НоваяСтрока, Новый Структура("Лексема,Тело,Строки,Параметры", Лексема, Тело, Новый Массив, Новый Массив));
	Возврат НоваяСтрока;
КонецФункции

Функция ИзвлечьПараметры(Знач Тело, ПараметрыИзСтроки)
	НовоеТело = Тело;

	НовоеТело = ВыделитьСтроковыеПараметры(НовоеТело, ПараметрыИзСтроки, "'");
	НовоеТело = ВыделитьСтроковыеПараметры(НовоеТело, ПараметрыИзСтроки, """");
	//Лог.Отладка("НовоеТело (после обработки строк) <"+ НовоеТело+">");

	НовоеТело = ВыделитьПараметрыДата(НовоеТело, ПараметрыИзСтроки);

	НовоеТело = ВыделитьЧисловыеПараметры(НовоеТело, ПараметрыИзСтроки);

	Возврат НовоеТело;
КонецФункции

Функция ВыделитьСтроковыеПараметры(Знач Тело, Параметры, Знач ЗнакКавычки)
	Итератор = Найти(Тело, ЗнакКавычки);
	Если Итератор = 0 Тогда
		Возврат Тело;
	КонецЕсли;

	ОстатокСтроки = Тело;
	НоваяСтрока = "";

	ВременныеПараметры = Новый Массив;

	Пока Итератор > 0 Цикл
		НоваяСтрока = НоваяСтрока + Лев(ОстатокСтроки, Итератор-1);
		ОстатокСтроки = Сред(ОстатокСтроки, Итератор+1);

		Итератор = Найти(ОстатокСтроки, ЗнакКавычки);
		Если Итератор > 0 Тогда
			ЗначениеПараметра = Лев(ОстатокСтроки, Итератор-1);
			ОстатокСтроки = Сред(ОстатокСтроки, Итератор+1);

			ОписаниеПараметра = ВозможныеКлючиПараметров.Строка;
			НоваяСтрока = НоваяСтрока + ОписаниеПараметра;
			ДобавитьПараметр(Параметры, ОписаниеПараметра, ЗначениеПараметра);
		Иначе
			НоваяСтрока = НоваяСтрока + ОстатокСтроки;
		КонецЕсли;

		Итератор = Найти(ОстатокСтроки, ЗнакКавычки);
		Если Итератор = 0 Тогда
			НоваяСтрока = НоваяСтрока + ОстатокСтроки;
		КонецЕсли;
	КонецЦикла;

	Возврат НоваяСтрока;
КонецФункции

Функция ВыделитьЧисловыеПараметры(Знач Тело, Параметры)
	РегулярноеВыражение = РегулярныеВыражения.ЧислоИлиСловоСЧислом;
	КоллекцияГруппСовпадений = РегулярноеВыражение.НайтиСовпадения(Тело);
	Если КоллекцияГруппСовпадений.Количество() = 0 Тогда
		Возврат Тело;
	КонецЕсли;

	НовоеТело = Тело;

	ВременныеПараметры = Новый Массив;

	Для к = -КоллекцияГруппСовпадений.Количество()+1 По 0 Цикл
		Группа = КоллекцияГруппСовпадений[-к];
		ЗначениеПараметра = Группа.Значение;
		Лог.Отладка("ЗначениеПараметра "+ЗначениеПараметра);
		ЭтоЧисловойПараметр = ЭтоЧисло(ЗначениеПараметра);
		ОписаниеПараметра = ?(ЭтоЧисловойПараметр, ВозможныеКлючиПараметров.Число, ВозможныеКлючиПараметров.Строка);

		ДобавитьПараметр(ВременныеПараметры, ОписаниеПараметра, ЗначениеПараметра);

		Начало = Группа.Индекс;
		Окончание = Группа.Индекс + Группа.Длина;
		НовоеТело = Лев(НовоеТело, Начало) + ОписаниеПараметра + Сред(НовоеТело, Окончание + 1);
	КонецЦикла;

	ДобавитьПараметрыВОбратномПорядке(Параметры, ВременныеПараметры);

	Возврат НовоеТело;

КонецФункции

Функция ВыделитьПараметрыДата(Знач Тело, Параметры)
	РегулярноеВыражение = РегулярныеВыражения.Дата;
	КоллекцияГруппСовпадений = РегулярноеВыражение.НайтиСовпадения(Тело);
	Если КоллекцияГруппСовпадений.Количество() = 0 Тогда
		Возврат Тело;
	КонецЕсли;

	НовоеТело = Тело;

	ВременныеПараметры = Новый Массив;

	Для к = -КоллекцияГруппСовпадений.Количество()+1 По 0 Цикл
		Группа = КоллекцияГруппСовпадений[-к];
		ЗначениеПараметра = Группа.Значение;
		Лог.Отладка("ЗначениеПараметра "+ЗначениеПараметра);
		ОписаниеПараметра = ВозможныеКлючиПараметров.Дата;

		ДобавитьПараметр(ВременныеПараметры, ОписаниеПараметра, ЗначениеПараметра);

		Начало = Группа.Индекс;
		Окончание = Группа.Индекс + Группа.Длина;
		НовоеТело = Лев(НовоеТело, Начало) + ОписаниеПараметра + Сред(НовоеТело, Окончание + 1);
	КонецЦикла;

	ДобавитьПараметрыВОбратномПорядке(Параметры, ВременныеПараметры);

	Возврат НовоеТело;

КонецФункции

Процедура ДобавитьПараметр(Параметры, Знач Тип, Знач Значение)
	Параметры.Добавить(Новый Структура("Тип,Значение", Тип, Значение));
КонецПроцедуры

Процедура ДобавитьПараметрыВОбратномПорядке(Параметры, ВременныеПараметры)
	Для к = -ВременныеПараметры.Количество()+1 По 0 Цикл
		Параметр = ВременныеПараметры[-к];
		ДобавитьПараметр(Параметры, Параметр.Тип, Параметр.Значение);
	КонецЦикла;
КонецПроцедуры

Функция ЭтоЧисло(Знач Строка)
	РегулярноеВыражение = РегулярныеВыражения.НеЧисло;
	Возврат Не РегулярноеВыражение.Совпадает(Строка);
КонецФункции

Функция НайтиТипШагаПоЛексеме(Знач Лексема)
	Возврат ТипыШагов[Лексема];

КонецФункции

Функция СформироватьАдресШага(Знач ТелоШага)
	АдресШага = "";

	МассивПодстрок = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(ТелоШага, " ", Истина);
	Для Каждого Элемент Из МассивПодстрок Цикл
		Если ЭтоКлючПараметра(Элемент) Тогда
			Лог.Отладка("Пропускаю Элемент "+Элемент);
			Продолжить;
		КонецЕсли;
		Элемент = СтрЗаменить(Элемент, "-", "_");
		АдресШага = АдресШага + ТРег(Элемент);
	КонецЦикла;

	Возврат АдресШага;
КонецФункции

Функция ЭтоКлючПараметра(Знач Строка)
	Для Каждого КлючЗначение Из ВозможныеКлючиПараметров Цикл
		Если КлючЗначение.Значение = Строка Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	Возврат Ложь;
КонецФункции

Функция ПолучитьЯзыкФичи(Знач ОчереднаяСтрока)
	Перем МЕТКА_ЯЗЫКА;

	МЕТКА_ЯЗЫКА = "language:";

	Язык = "";
	Поз = Найти(ОчереднаяСтрока, МЕТКА_ЯЗЫКА);
	Если  Поз > 0 Тогда
		Язык = СокрЛП(Сред(ОчереднаяСтрока, Поз+СтрДлина(МЕТКА_ЯЗЫКА)));
	КонецЕсли;
	Возврат Язык;
КонецФункции

Функция ВозможныеТипыНачалаСтроки()
	Рез = Новый Структура;
	Рез.Вставить("Комментарий", "#");
	Рез.Вставить("Метка", "@");
	Рез.Вставить("Пример", "|");
	Рез.Вставить("ОбычныйТекст", 1);
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции

Функция Инициализация()
	Лог = Логирование.ПолучитьЛог(ИмяЛога());

	Язык = "ru";

	ВозможныеКлючевыеСлова = ВозможныеКлючевыеСлова();
	ВозможныеТипыШагов = ВозможныеТипыШагов();
	ВозможныеТипыНачалаСтроки = ВозможныеТипыНачалаСтроки();
	ВозможныеКлючиПараметров = ВозможныеКлючиПараметров();

	ОписанияЛексем = ОписанияЛексем();

	УровниЛексем = ПолучитьУровниЛексем();
	ТипыШагов = ПолучитьТипыШагов();

	СоответствиеЯзыкКлючевыеСлова = Создать_СоответствиеЯзыкКлючевыеСлова();
	СоответствиеКлючевыеСлова = СоответствиеЯзыкКлючевыеСлова.Получить(Язык);

	РегулярныеВыражения = СоздатьРегулярныеВыражения();
КонецФункции

Функция Создать_СоответствиеЯзыкКлючевыеСлова()
	Рез = Новый Соответствие;
	Рез.Вставить("ru", СоздатьСоответствиеКлючевыхСлов_ru());
	Возврат Рез;
КонецФункции

Функция СоздатьСоответствиеКлючевыхСлов_ru()
	Рез = Новый Соответствие;

	Рез.Вставить("допустим", ВозможныеКлючевыеСлова.Допустим);
	Рез.Вставить("дано", ВозможныеКлючевыеСлова.Допустим);
	Рез.Вставить("пусть", ВозможныеКлючевыеСлова.Допустим);

	Рез.Вставить("если", ВозможныеКлючевыеСлова.Когда);
	Рез.Вставить("когда", ВозможныеКлючевыеСлова.Когда);

	Рез.Вставить("тогда", ВозможныеКлючевыеСлова.Тогда);
	Рез.Вставить("то", ВозможныеКлючевыеСлова.Тогда);

	Рез.Вставить("и", ВозможныеКлючевыеСлова.Также);
	Рез.Вставить("к тому же", ВозможныеКлючевыеСлова.Также);
	Рез.Вставить("также", ВозможныеКлючевыеСлова.Также);

	Рез.Вставить("но", ВозможныеКлючевыеСлова.Но);
	Рез.Вставить("а", ВозможныеКлючевыеСлова.Но);

	Рез.Вставить("функциональность", ВозможныеКлючевыеСлова.Функциональность);
	Рез.Вставить("функционал", ВозможныеКлючевыеСлова.Функциональность);
	Рез.Вставить("функция", ВозможныеКлючевыеСлова.Функциональность);
	Рез.Вставить("свойство", ВозможныеКлючевыеСлова.Функциональность);

	Рез.Вставить("предыстория", ВозможныеКлючевыеСлова.Контекст);
	Рез.Вставить("контекст", ВозможныеКлючевыеСлова.Контекст);
	Рез.Вставить("сценарий",  ВозможныеКлючевыеСлова.Сценарий);
	Рез.Вставить("структура сценария", ВозможныеКлючевыеСлова.СтруктураСценария);

	Рез.Вставить("примеры", ВозможныеКлючевыеСлова.Примеры);

	Возврат Рез;
КонецФункции

Функция ОписанияЛексем()
	Рез = Новый ТаблицаЗначений;
	Рез.Колонки.Добавить("Ключ");
	Рез.Колонки.Добавить("Лексема");
	Рез.Колонки.Добавить("ТипШага");
	Рез.Колонки.Добавить("Уровень");

	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Функциональность, ВозможныеТипыШагов.Функциональность, 0);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Контекст, ВозможныеТипыШагов.Контекст, 5);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Примеры, ВозможныеТипыШагов.Примеры, 5);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Сценарий, ВозможныеТипыШагов.Сценарий, 20);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.СтруктураСценария, ВозможныеТипыШагов.СтруктураСценария, 20);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Допустим, ВозможныеТипыШагов.Шаг, 100);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Когда, ВозможныеТипыШагов.Шаг, 100);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Тогда, ВозможныеТипыШагов.Шаг, 100);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Также, ВозможныеТипыШагов.Шаг, 100);
	ДобавитьЛексему(Рез, ВозможныеКлючевыеСлова.Но, ВозможныеТипыШагов.Шаг, 100);

	Возврат Рез;
КонецФункции

Функция ДобавитьЛексему(Таблица, Ключ, ТипШага, Уровень)
	НоваяСтрока = Таблица.Добавить();
	НоваяСтрока.Ключ = Ключ;
	НоваяСтрока.Лексема = Ключ;
	НоваяСтрока.ТипШага = ТипШага;
	НоваяСтрока.Уровень = Уровень;
КонецФункции

Функция ПолучитьУровниЛексем()
	Рез = Новый Структура;
	Для каждого Строка Из ОписанияЛексем Цикл
		Рез.Вставить(Строка.Ключ, Строка.Уровень);
	КонецЦикла;
	Возврат Рез;
КонецФункции

Функция ПолучитьТипыШагов()
	Рез = Новый Структура;
	Для каждого Строка Из ОписанияЛексем Цикл
		Рез.Вставить(Строка.Ключ, Строка.ТипШага);
	КонецЦикла;
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции

Функция СоздатьРегулярныеВыражения()
	Рез = Новый Структура;
	Рез.Вставить("НеЧисло", Новый РегулярноеВыражение("[^\d]+"));
	Рез.Вставить("Дата", Новый РегулярноеВыражение("\d{2}.\d{2}.\d{2,4}"));
	Рез.Вставить("ЧислоИлиСловоСЧислом", Новый РегулярноеВыражение("([а-яё\w]*\d+[а-яё\w]*)|(-?\d+(,\d)*)+")); //Когда я использую 5 как 5число5
		//РегулярноеВыражение = Новый РегулярноеВыражение("(-?\d+(,\d)*)+");
		//РегулярноеВыражение = Новый РегулярноеВыражение("([а-яё\w]*\d+[а-яё\w]*)|(-?\d+(,\d)*)+"); //Когда я использую 5 как 5число5
		//РегулярноеВыражение = Новый РегулярноеВыражение("(-{1}\d+)+");
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции // СоздатьРегулярныеВыражения()
// }

///////////////////////////////////////////////////////////////////
// Точка входа

Инициализация();
