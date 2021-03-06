//----------------------------------------------------------
//This Source Code Form is subject to the terms of the
//Mozilla Public License, v.2.0. If a copy of the MPL
//was not distributed with this file, You can obtain one
//at http://mozilla.org/MPL/2.0/.
//----------------------------------------------------------

/////////////////////////////////////////////////////////////////
//
// Объект-помощник для выполнения приемочного/BDD тестирования
//
//////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать asserts
#Использовать strings

Перем Лог;
Перем ЧитательГеркин;

Перем ПредставленияСтатусовВыполнения;
Перем ВозможныеСтатусыВыполнения;
Перем ВозможныеТипыШагов;
Перем ВозможныеКлючиПараметров;
Перем ВозможныеЦветаСтатусовВыполнения;

Перем ТекущийУровень;

////////////////////////////////////////////////////////////////////
//{ Программный интерфейс

Функция ВыполнитьФичу(Знач ФайлФичи, Знач ФайлБиблиотек = Неопределено, Знач ИскатьВПодкаталогах = Истина) Экспорт
	НаборБиблиотечныхШагов = ПолучитьНаборБиблиотечныхШагов(ФайлБиблиотек);
	Лог.Отладка(СтрШаблон("Найдено библиотечных шагов: %1 шт.", ?(ЗначениеЗаполнено(НаборБиблиотечныхШагов), НаборБиблиотечныхШагов.Количество(), "0")));

	Если ФайлФичи.ЭтоКаталог() Тогда
		Лог.Отладка("Подготовка к выполнению сценариев в каталоге "+ФайлФичи.ПолноеИмя);
		МассивФайлов = НайтиФайлы(ФайлФичи.ПолноеИмя, "*.feature", ИскатьВПодкаталогах);

		НаборРезультатовВыполнения = Новый Массив;
		Для каждого ФайлФичи Из МассивФайлов Цикл
			Если ФайлФичи.ЭтоКаталог() Тогда
				ВызватьИсключение "Нашли каталог вместо файла-фичи "+ФайлФичи.ПолноеИмя;
			КонецЕсли;
			РезультатВыполнения = ВыполнитьФичуСУчетомБиблиотечныхШагов(ФайлФичи, НаборБиблиотечныхШагов);;
			НаборРезультатовВыполнения.Добавить(РезультатВыполнения);
		КонецЦикла;
		РезультатыВыполнения = СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения);

	Иначе

		РезультатыВыполнения = ВыполнитьФичуСУчетомБиблиотечныхШагов(ФайлФичи, НаборБиблиотечныхШагов);

	КонецЕсли;

	Возврат РезультатыВыполнения;
КонецФункции

Процедура ВывестиИтоговыеРезультатыВыполнения(РезультатыВыполнения) Экспорт
	МассивИтогов = Новый Массив;
	МассивИтогов.Добавить(ВозможныеТипыШагов.Функциональность);
	МассивИтогов.Добавить(ВозможныеТипыШагов.Сценарий);
	МассивИтогов.Добавить(ВозможныеТипыШагов.Шаг);

	СтруктураИтогов = Новый Структура;
	Для каждого Элем Из МассивИтогов Цикл
		СтруктураИтогов.Вставить(Элем, СтатусыВыполненияДляПодсчета());
	КонецЦикла;

	РекурсивноПосчитатьИтогиВыполнения(РезультатыВыполнения.Строки[0], СтруктураИтогов);

	ИмяПоляИтога = "Итог";
	Для каждого Итоги Из СтруктураИтогов Цикл
		ДобавитьОбщееКоличествоКИтогам(Итоги.Ключ, Итоги.Значение, ИмяПоляИтога);
	КонецЦикла;

	ТекущийУровень = 0;
	Лог.Информация("");

	Для каждого Элем Из МассивИтогов Цикл
		Итог = СтруктураИтогов[Элем];
		ВыводимИтог = Истина;
		Если Элем = ВозможныеТипыШагов.Функциональность И Итог[ИмяПоляИтога] = 1 Тогда
			ВыводимИтог = Ложь;
		КонецЕсли;
		Если ВыводимИтог Тогда
			ВывестиПредставлениеИтога(Итог, Элем, ИмяПоляИтога);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

// Статусы выполнения тестов - ВАЖЕН порядок значение (0,1...), используется в ЗапомнитьСамоеХудшееСостояние
Функция ВозможныеСтатусыВыполнения() Экспорт
	Рез = Новый Структура;
	Рез.Вставить("НеВыполнялся", "0 Не выполнялся"); // использую подобное текстовое значение для удобных ассертов при проверке статусов выполнения
	Рез.Вставить("Пройден", "1 пройден");
	Рез.Вставить("НеРеализован", "2 не реализован");
	Рез.Вставить("Сломался", "3 Сломался");
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции

Функция ВозможныеКодыВозвратовПроцесса() Экспорт
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, 1);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, 2);
	Возврат Рез;
КонецФункции // ВозможныеКодыВозвратовПроцесса()

Функция ИмяЛога() Экспорт
	Возврат "bdd";
КонецФункции

//}

////////////////////////////////////////////////////////////////////
//{ Реализация

Функция ВыполнитьФичуСУчетомБиблиотечныхШагов(Знач ФайлФичи, Знач НаборБиблиотечныхШагов)
	Лог.Отладка("Подготовка к выполнению сценария "+ФайлФичи.ПолноеИмя);

	Лог.Отладка("Читаю фичу");

	Лог.Отладка(СтрШаблон("Найдено библиотечных шагов: %1 шт.", ?(ЗначениеЗаполнено(НаборБиблиотечныхШагов), НаборБиблиотечныхШагов.Количество(), "0")));

	РезультатыРазбора = ЧитательГеркин.ПрочитатьФайлСценария(ФайлФичи);

	РезультатыВыполнения = ВыполнитьДеревоФич(ФайлФичи, НаборБиблиотечныхШагов, РезультатыРазбора);

	Возврат РезультатыВыполнения;
КонецФункции

// возвращает Неопределено, если не найдено, или соответствие, где ключ - имя шага, значение - объект-исполнитель шага (os-скрипт)
Функция ПолучитьНаборБиблиотечныхШагов(Знач ФайлБиблиотек) Экспорт //TODO перенести в секцию публичных методов или вообще в другой класс
	Если Не ЗначениеЗаполнено(ФайлБиблиотек) Тогда
		Возврат Неопределено
	КонецЕсли;
	КоллекцияШагов = Новый Структура;

	Лог.Отладка("Получение всех шагов из библиотеки "+ФайлБиблиотек.ПолноеИмя);
	МассивОписанийИсполнителяШагов = ПолучитЬМассивОписанийИсполнителяШагов(ФайлБиблиотек);
	Для каждого ОписаниеИсполнителяШагов Из МассивОписанийИсполнителяШагов Цикл
		Исполнитель = ОписаниеИсполнителяШагов.Исполнитель;
		МассивОписанийШагов = ПолучитьМассивОписанийШагов(Исполнитель);
		Для каждого ИмяШага Из МассивОписанийШагов Цикл
			АдресШага = ЧитательГеркин.НормализоватьАдресШага(ИмяШага);
			Если Не КоллекцияШагов.Свойство(АдресШага) Тогда
				КоллекцияШагов.Вставить(АдресШага, ОписаниеИсполнителяШагов);
				Лог.Отладка(СтрШаблон("Найдено имя шага <%1>, источник %2", ИмяШага, ОписаниеИсполнителяШагов.Файл.Имя));
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	Возврат КоллекцияШагов;
КонецФункции // ПолучитьНаборБиблиотечныхШагов(ФайлБиблиотек)

Функция ПолучитЬМассивОписанийИсполнителяШагов(Знач ФайлБиблиотек)
	МассивОписанийИсполнителяШагов = Новый Массив;
	Если Не ФайлБиблиотек.ЭтоКаталог() Тогда
		ОписаниеИсполнителяШагов = НайтиИсполнителяШагов(ФайлБиблиотек);
		Если ЗначениеЗаполнено(ОписаниеИсполнителяШагов) Тогда
			МассивОписанийИсполнителяШагов.Добавить(ОписаниеИсполнителяШагов);
			Лог.Отладка("Нашли исполнителя шагов "+ФайлБиблиотек.ПолноеИмя);
		КонецЕсли;
	Иначе
		МассивФайлов = НайтиФайлы(ФайлБиблиотек.ПолноеИмя, "*.os", Истина);

		Для каждого ФайлИсполнителя Из МассивФайлов Цикл
			Если ФайлИсполнителя.ЭтоКаталог() Тогда
				ВызватьИсключение "Нашли каталог вместо файла-шага "+ФайлИсполнителя.ПолноеИмя;
			КонецЕсли;

			ОписаниеИсполнителяШагов = ПолучитьИсполнителяШагов(ФайлИсполнителя);
			Если ЗначениеЗаполнено(ОписаниеИсполнителяШагов) Тогда
				МассивОписанийИсполнителяШагов.Добавить(ОписаниеИсполнителяШагов);
				Лог.Отладка("Нашли исполнителя шагов "+ФайлИсполнителя.ПолноеИмя);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Возврат МассивОписанийИсполнителяШагов;
КонецФункции // ПолучитЬМассивОписанийИсполнителяШагов(ФайлБиблиотек)

Функция ВыполнитьДеревоФич(Знач ФайлСценария, Знач НаборБиблиотечныхШагов, РезультатыРазбора)

	ДеревоФич = РезультатыРазбора.ДеревоФич;
	Ожидаем.Что(ДеревоФич, "Ожидали, что дерево фич будет передано как дерево значений, а это не так").ИмеетТип("ДеревоЗначений");

	РезультатыВыполнения = ДеревоФич.Скопировать();
	РекурсивноУстановитьСтатусДляВсехУзлов(РезультатыВыполнения.Строки[0], ВозможныеСтатусыВыполнения.НеВыполнялся);

	НаборБиблиотечныхШагов = ДополнитьНаборШаговИзИсполнителяШаговФичи(ФайлСценария, НаборБиблиотечныхШагов);

	РезультатыВыполнения.Строки[0].СтатусВыполнения = РекурсивноВыполнитьШаги(НаборБиблиотечныхШагов, РезультатыВыполнения.Строки[0]);

	Возврат РезультатыВыполнения;
КонецФункции

Функция ДополнитьНаборШаговИзИсполнителяШаговФичи(Знач ФайлСценария, Знач НаборБиблиотечныхШагов)
	ОписаниеИсполнителяШагов = НайтиИсполнителяШагов(ФайлСценария);
	Если ОписаниеИсполнителяШагов <> Неопределено Тогда

		НаборШаговИсполнителя = ПолучитьНаборБиблиотечныхШагов(ФайлСценария);
		Если ЗначениеЗаполнено(НаборШаговИсполнителя) Тогда
			Лог.Отладка(СтрШаблон("найдено шагов исполнителя %1", НаборШаговИсполнителя.Количество()));
		КонецЕсли;
		Если ЗначениеЗаполнено(НаборБиблиотечныхШагов) Тогда
			Для каждого КлючЗначение Из НаборШаговИсполнителя Цикл
				НаборБиблиотечныхШагов.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
			КонецЦикла;
		Иначе
			НаборБиблиотечныхШагов = НаборШаговИсполнителя;
			Если Не ЗначениеЗаполнено(НаборБиблиотечныхШагов) Тогда
				ВызватьИсключение СтрШаблон("Не найдено шагов для фичи %1", ФайлСценария.ПолноеИмя);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат НаборБиблиотечныхШагов;
КонецФункции

Функция ПолучитьМассивОписанийШагов(Знач ИсполнительШагов)
	Рефлектор = Новый Рефлектор;
	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(ЭтотОбъект);
	МассивОписанийШагов = Рефлектор.ВызватьМетод(ИсполнительШагов, ЧитательГеркин.НаименованиеФункцииПолученияСпискаШагов(), МассивПараметров);
	Возврат МассивОписанийШагов;
КонецФункции // ПолучитьМассивОписанийШагов()

Функция НайтиИсполнителяШагов(Знач ФайлСценария)
	Лог.Отладка("Ищу исполнителя шагов в каталоге "+ФайлСценария.Путь);
	ПутьКИсполнителю = ОбъединитьПути(ФайлСценария.Путь, "step_definitions");
	ПутьКИсполнителю = ОбъединитьПути(ПутьКИсполнителю, ФайлСценария.ИмяБезРасширения+ ".os");

	ФайлИсполнителя = Новый Файл(ПутьКИсполнителю);
	ОписаниеИсполнителя = ПолучитьИсполнителяШагов(ФайлИсполнителя);
	Возврат ОписаниеИсполнителя;
КонецФункции

Функция ПолучитьИсполнителяШагов(Знач ФайлИсполнителя)
	Лог.Отладка("Ищу исполнителя шагов в файле "+ФайлИсполнителя.ПолноеИмя);

	Если ФайлИсполнителя.Существует() Тогда
		ИсполнительШагов = ЗагрузитьСценарий(ФайлИсполнителя.ПолноеИмя);
		
		ОписаниеИсполнителя = Новый Структура("Исполнитель,Файл", ИсполнительШагов, ФайлИсполнителя);
	Иначе
		ОписаниеИсполнителя = Неопределено;
	КонецЕсли;
	
	Возврат ОписаниеИсполнителя;
КонецФункции // ПолучитьИсполнителяШагов()

Функция РекурсивноВыполнитьШаги(Знач НаборБиблиотечныхШагов, Знач Узел)
	ТекущийУровень = Узел.Уровень();
	ПредставлениеЛексемы = ?(Узел.ТипШага <> ВозможныеТипыШагов.Описание, Узел.Лексема +" ", "");
	Если Узел.ТипШага <> ВозможныеТипыШагов.Шаг Тогда
		Лог.Информация(ПредставлениеЛексемы + Узел.Тело);
	КонецЕсли;

	Лог.Отладка(СтрШаблон("Выполняю узел <%1>, адрес <%2>, тело <%3>", Узел.ТипШага, Узел.АдресШага, Узел.Тело));
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;

	СтатусВыполнения = ВыполнитьДействиеУзла(НаборБиблиотечныхШагов, Узел);

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		НовыйСтатус = РекурсивноВыполнитьШаги(НаборБиблиотечныхШагов, СтрокаДерева);
		СтатусВыполнения = ЗапомнитьСамоеХудшееСостояние(СтатусВыполнения, НовыйСтатус);
		Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Пройден и СтрокаДерева.ТипШага = ВозможныеТипыШагов.Шаг Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Узел.СтатусВыполнения = СтатусВыполнения;

	Если Узел.ТипШага <> ВозможныеТипыШагов.Шаг И Узел.ТипШага <> ВозможныеТипыШагов.Описание Тогда
		Лог.Информация("");
	КонецЕсли;

	Возврат СтатусВыполнения;
КонецФункции

Функция ВыполнитьДействиеУзла(Знач НаборБиблиотечныхШагов, Знач Узел)

	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	Если Узел.ТипШага = ВозможныеТипыШагов.Шаг Тогда
		СтатусВыполнения = ВыполнитьШаг(Узел.АдресШага, Узел.Параметры, НаборБиблиотечныхШагов, Узел.Тело);

		Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Пройден Тогда
			Отступ = ПолучитьОтступ(ТекущийУровень);
			Лог.Информация(Отступ + ПредставленияСтатусовВыполнения[СтатусВыполнения]);
		КонецЕсли;
	ИначеЕсли Узел.ТипШага = ВозможныеТипыШагов.Описание Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден;
	КонецЕсли;
	Узел.СтатусВыполнения = СтатусВыполнения;

	Возврат СтатусВыполнения;
КонецФункции

Функция ВыполнитьШаг(Знач АдресШага, Знач ПараметрыШага, Знач НаборБиблиотечныхШагов, Знач ПредставлениеШага)
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;

	ОписаниеИсполнителяШагов = НаборБиблиотечныхШагов[ЧитательГеркин.НормализоватьАдресШага(АдресШага)];
	Если ОписаниеИсполнителяШагов = Неопределено Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
	Иначе
		Рефлектор = Новый Рефлектор;

		СтрокаПараметров = "";
		МассивПараметров = Новый Массив;
		ПолучитьМассивПараметров(МассивПараметров, ПараметрыШага, СтрокаПараметров);

		СтрокаПараметров = Лев(СтрокаПараметров, СтрДлина(СтрокаПараметров)-1);
		Лог.Отладка(СтрШаблон("	Выполняю шаг <%1>, параметры <%2>, источник %3", 
			АдресШага, СтрокаПараметров, ОписаниеИсполнителяШагов.Файл.Имя));

		Попытка
			Рефлектор.ВызватьМетод(ОписаниеИсполнителяШагов.Исполнитель, АдресШага, МассивПараметров);
			СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден;
			
		Исключение

			текстОшибки = ОписаниеОшибки();
			Инфо = ИнформацияОбОшибке();

			//TODO обход бага https://github.com/EvilBeaver/OneScript/pull/274 баг использования параметров исключения при обычном исключении
			//{ Если Инфо.Параметры = ЧитательГеркин.ПараметрИсключенияДляЕщеНеРеализованногоШага() Тогда
			ЗначениеПараметраИсключения = Неопределено;
			Попытка
				ЗначениеПараметраИсключения = Инфо.Параметры;
			Исключение
			КонецПопытки;
			Если ЗначениеПараметраИсключения = ЧитательГеркин.ПараметрИсключенияДляЕщеНеРеализованногоШага() Тогда
			//}
				СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
			ИначеЕсли Инфо.Описание = СтрШаблон("Метод объекта не обнаружен (%1)", АдресШага) Тогда //вдруг сняли Экспорт с метода
				СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
			Иначе
				СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
				ПредставлениеШага = ПредставлениеШага + Символы.ПС + текстОшибки;
			КонецЕсли;

		КонецПопытки;
		ВывестиСообщение(ПредставлениеШага, СтатусВыполнения);
	КонецЕсли;

	Возврат СтатусВыполнения;
КонецФункции // ВыполнитьШаг()

Процедура ПолучитьМассивПараметров(МассивПараметров, Знач Параметры, РезСтрокаПараметров)
	Если ЗначениеЗаполнено(Параметры) Тогда
		Для Каждого КлючЗначение Из Параметры Цикл
			МассивПараметров.Добавить(КлючЗначение.Значение);
			РезСтрокаПараметров = РезСтрокаПараметров + КлючЗначение.Значение + ",";
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

Функция СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения)
	РезультатВыполнения = ЧитательГеркин.СоздатьДеревоФич();
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;

	Для каждого РезультатВыполненияФичи Из НаборРезультатовВыполнения Цикл
		Подстрока = РезультатВыполнения.Строки.Добавить();
		ЧитательГеркин.СкопироватьДерево(Подстрока, РезультатВыполненияФичи.Строки[0]);
		СтатусВыполнения = ЗапомнитьСамоеХудшееСостояние(СтатусВыполнения, Подстрока.СтатусВыполнения);
	КонецЦикла;
	Возврат РезультатВыполнения;
КонецФункции // СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения)

Процедура РекурсивноПосчитатьИтогиВыполнения(Узел, СтруктураИтогов)
	НужныйИтог = Неопределено;
	ЕстьИтог = СтруктураИтогов.Свойство(Узел.ТипШага, НужныйИтог);
	Если НЕ ЕстьИтог Тогда
		Возврат;
	КонецЕсли;

	НужныйИтог[Узел.СтатусВыполнения] = НужныйИтог[Узел.СтатусВыполнения] + 1;

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		РекурсивноПосчитатьИтогиВыполнения(СтрокаДерева, СтруктураИтогов);
	КонецЦикла;
КонецПроцедуры

Процедура ДобавитьОбщееКоличествоКИтогам(ИмяИтогов, Итоги, ИмяПоляИтога)
	Счетчик = 0;
	Для каждого Итог Из Итоги Цикл
		Счетчик = Счетчик + Итог.Значение;
	КонецЦикла;
	Итоги.Вставить(ИмяПоляИтога, Счетчик);
КонецПроцедуры

Процедура ВывестиПредставлениеИтога(Итог, ПредставлениеШага, ИмяПоляИтога)
	Представление = СтрШаблон("%9 %10 ( %1 %2, %3 %4, %5 %6, %7 %8 )",
		Итог[ВозможныеСтатусыВыполнения.Пройден], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.Пройден],
		Итог[ВозможныеСтатусыВыполнения.НеРеализован], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.НеРеализован],
		Итог[ВозможныеСтатусыВыполнения.Сломался], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.Сломался],
		Итог[ВозможныеСтатусыВыполнения.НеВыполнялся], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.НеВыполнялся],
		Итог[ИмяПоляИтога], ПредставлениеШага
		);
	Лог.Информация(Представление);
КонецПроцедуры

Процедура РекурсивноУстановитьСтатусДляВсехУзлов(Узел, НовыйСтатус)
	Узел.СтатусВыполнения = НовыйСтатус;

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		РекурсивноУстановитьСтатусДляВсехУзлов(СтрокаДерева, НовыйСтатус);
	КонецЦикла;
КонецПроцедуры

// Устанавливает новое текущее состояние выполнения тестов
// в соответствии с приоритетами состояний:
// 		Красное - заменяет все другие состояния
// 		Желтое - заменяет только зеленое состояние
// 		Зеленое - заменяет только серое состояние (тест не выполнялся ни разу).
Функция ЗапомнитьСамоеХудшееСостояние(ТекущееСостояние, НовоеСостояние)
	ТекущееСостояние = Макс(ТекущееСостояние, НовоеСостояние);
	Возврат ТекущееСостояние;

КонецФункции

// реализация интерфейс раскладки для логов
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	Отступ = ПолучитьОтступ(ТекущийУровень);
	НаименованиеУровня = "";

	Если Уровень = УровниЛога.Информация Тогда
		НаименованиеУровня = ?(Лог.Уровень() <> Уровень, УровниЛога.НаименованиеУровня(Уровень) +Символы.Таб+ "- ", "");
		Сообщение = СтроковыеФункции.ДополнитьСлеваМногострочнуюСтроку(Сообщение, Отступ);
		Возврат СтрШаблон("%1%2", НаименованиеУровня, Сообщение);
	КонецЕсли;
	
	НаименованиеУровня = УровниЛога.НаименованиеУровня(Уровень);
	
	Сообщение = СтроковыеФункции.ДополнитьСлеваМногострочнуюСтроку(Сообщение, СтрШаблон("- %1", Отступ));
	Возврат СтрШаблон("%1 %2 %3", НаименованиеУровня, Символы.Таб, Сообщение);

КонецФункции

//TODO здесь нужно использовать различные виды форматирования
Процедура ВывестиСообщение(Знач Сообщение, Знач СтатусВыполнения)
	Консоль = Новый Консоль();
	//ПредыдущийЦветТекстаКонсоли = Консоль.ЦветТекста; //TODO если раскомментировать, будет баг
	ПредыдущийЦветТекстаКонсоли = ЦветКонсоли.Белый;
	
	НовыйЦветТекста = ВозможныеЦветаСтатусовВыполнения[СтатусВыполнения];
	Если НовыйЦветТекста = Неопределено Тогда
		НовыйЦветТекста = ПредыдущийЦветТекстаКонсоли;
	КонецЕсли;
	Консоль.ЦветТекста = НовыйЦветТекста;

	Если СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден Тогда
		Лог.Информация(Сообщение);
	ИначеЕсли СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался Тогда
		Лог.Ошибка(Сообщение);
	ИначеЕсли СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован Тогда
		Лог.Предупреждение(Сообщение);
	КонецЕсли;
	Консоль.ЦветТекста = ПредыдущийЦветТекстаКонсоли;
КонецПроцедуры

Функция ПолучитьОтступ(Количество)
	Возврат СтроковыеФункции.СформироватьСтрокуСимволов(" ", Количество* 3);
КонецФункции

Функция ВозможныеЦветаСтатусовВыполнения()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, Неопределено);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, ЦветКонсоли.Зеленый);
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, ЦветКонсоли.Серый);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, ЦветКонсоли.Красный);

	Возврат Новый ФиксированноеСоответствие(Рез);
КонецФункции

Функция ЗаполнитьПредставленияСтатусовВыполнения()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, "Не выполнялся");
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, "Пройден");
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, "Не реализован");
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, "Сломался");
	Возврат Рез;
КонецФункции

Функция СтатусыВыполненияДляПодсчета()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, 0);
	Возврат Рез;
КонецФункции // СтатусыВыполнения()

Функция Инициализация()
	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	Лог.УстановитьРаскладку(ЭтотОбъект);

	ВозможныеСтатусыВыполнения = ВозможныеСтатусыВыполнения();
	ПредставленияСтатусовВыполнения = ЗаполнитьПредставленияСтатусовВыполнения();
	ВозможныеЦветаСтатусовВыполнения = ВозможныеЦветаСтатусовВыполнения();
	ТекущийУровень = 0;

	ЧитательГеркин = ЗагрузитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "gherkin-read.os"));

	ВозможныеТипыШагов = ЧитательГеркин.ВозможныеТипыШагов();
	ВозможныеКлючиПараметров = ЧитательГеркин.ВозможныеКлючиПараметров();
КонецФункции

// }

///////////////////////////////////////////////////////////////////
// Точка входа

Инициализация();
