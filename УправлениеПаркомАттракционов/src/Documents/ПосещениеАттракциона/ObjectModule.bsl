// @strict-types

#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ,Режим)

	Движения.АктивныеПосещения.Записывать = Истина;
	Движения.Записать();

	Выборка = АктивныеПосещения();
	
	ОсталосьПосещений = 0;
	ВидАттракционаАбонемента = Неопределено;
	ВидАттракционаДокумента  = Неопределено; //см. ВидАттракциона
	
	
	Если Выборка.Следующий() Тогда
		ОсталосьПосещений = Выборка.КоличествоПесещенийОстаток;
		ВидАттракционаАбонемента = Выборка.ВидАттракциона;
	КонецЕсли;	

	Если ОсталосьПосещений < 1 Тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "В билете не осталось посещений.";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Поле = "Основание";
		Сообщение.Сообщить();
	КонецЕсли;	

	ВидАттракционаДокумента = ВидАттракциона(Аттракцион);
	Если ЗначениеЗаполнено(ВидАттракционаАбонемента) И
		 ВидАттракционаДокумента <> ВидАттракционаАбонемента Тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Билет не подходит для посещения этого аттракциона.";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Поле = "Основание";
		Сообщение.Сообщить();
	КонецЕсли;	
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	// регистр АктивныеПосещения
	Движения.АктивныеПосещения.Записывать = Истина;
	Движение = Движения.АктивныеПосещения.Добавить();
	Движение.Период = Дата;
	Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
	Движение.Основание = Основание;
	Движение.ВидАттракциона = ВидАттракционаАбонемента;
	Движение.КоличествоПесещений = 1;
	
	// регистр ПосещенияАттракционов
	Движения.ПосещенияАттракционов.Записывать = Истина;
	ДвижениеПосещенияАттракционов = Движения.ПосещенияАттракционов.Добавить();
	ДвижениеПосещенияАттракционов.Период = Дата;
	ДвижениеПосещенияАттракционов.Аттракцион = Аттракцион;
	ДвижениеПосещенияАттракционов.Клиент = КлиентПоОснованию();
	ДвижениеПосещенияАттракционов.Количество = 1;
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Ответственный = Пользователи.ТекущийПользователь();
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	Ответственный = Пользователи.ТекущийПользователь();
КонецПроцедуры
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Активные посещения.
// 
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса - Активные посещения:
//  *ВидАттракциона - СправочникСсылка.ВидыАттракционов
//  *КоличествоПесещенийОстаток - Число
//  
Функция АктивныеПосещения()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	АктивныеПосещенияОстатки.КоличествоПесещенийОстаток,
	|	АктивныеПосещенияОстатки.ВидАттракциона
	|ИЗ
	|	РегистрНакопления.АктивныеПосещения.Остатки(, Основание = &Основание) КАК АктивныеПосещенияОстатки";
	
	Запрос.УстановитьПараметр("Основание",Основание );
	Выборка = Запрос.Выполнить().Выбрать();
	Возврат Выборка
КонецФункции

// Вид аттракциона.
// 
// Параметры:
//  Аттракцион - СправочникСсылка.Аттракционы - Аттракцион
// 
// Возвращаемое значение:
// 
//  ВидАттракциона - СправочникСсылка.ВидыАттракционов
// 
// 
Функция ВидАттракциона(Аттракцион)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Аттракционы.ВидАттракциона
	|ИЗ
	|	Справочник.Аттракционы КАК Аттракционы
	|ГДЕ
	|	Аттракционы.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Аттракцион);
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	Возврат Выборка.ВидАттракциона;
КонецФункции	

Функция КлиентПоОснованию()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ПродажаБилетов.Клиент
	|ИЗ
	|	Документ.ПродажаБилетов КАК ПродажаБилетов
	|ГДЕ
	|	ПродажаБилетов.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", Основание);
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	Возврат Выборка.Клиент;
КонецФункции
	
#КонецОбласти

#КонецЕсли