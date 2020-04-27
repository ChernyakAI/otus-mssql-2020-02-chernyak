using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

namespace Declination
{
    public class UserDefinedFunctions
	{

		[SqlFunction()]

		public static string DeclineFIO(SqlString _fio, SqlString _declineCase)
		{

			string result = _fio.ToString().Replace("ё", "е");
			string declineCase = _declineCase.ToString();

			string[] words = result.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
			if (words.Count() < 3)
			{
				return "Ошибка: ФИО указано не полностью.";
			}
			if (!Regex.IsMatch(result, @"^[а-яА-Я]{3,}\s[а-яА-Я]{3,}\s[а-яА-Я ]{3,}$"))
			{
				return "Ошибка: недопустимая строка ФИО.";
			}

			string firstName = words[1].ToLower();
			string lastName = words[0].ToLower();
			string middleName = "";

			if (words.Count() > 3)
			{
				for (int i = 2; i < words.Count(); i++)
				{
					middleName += " ";
					middleName += words[i];
				}
			}
			else
			{
				middleName = words[2];
			}

			middleName = middleName.Trim().ToLower();

			string gender = CheckGender(middleName);
			string _lastName = DeclineLastName(lastName, declineCase, gender);

			return _lastName.Substring(0, 1).ToUpper() + _lastName.Substring(1) + " " + firstName.Substring(0, 1).ToUpper() + " " + middleName.Substring(0, 1).ToUpper();

		}

		static string CheckGender(String middleName)
		{

			string result = "";
			string lastThreeSymbols = middleName.Substring(middleName.Length - 3);
			string lastFourSymbols = middleName.Substring(middleName.Length - 4);

			if (middleName == "кузьмич" || middleName == "фомич" || middleName == "ильич" || middleName == "лукич")
			{
				result = "male";
			}
			else if (lastThreeSymbols == "улы")
			{
				result = "male";
			}
			else if (lastFourSymbols == "ович" || lastFourSymbols == "евич" || lastFourSymbols == "оглы")
			{
				result = "male";
			}
			else if (lastFourSymbols == "овна" || lastFourSymbols == "евна" || lastFourSymbols == "кызы" || lastFourSymbols == "ична" || lastFourSymbols == "гызы")
			{
				result = "female";
			}

			return result;

		}

		static string DeclineLastName(string secondName, string declineCase, string gender)
		{
			string result = secondName;

			string lastOneChar = result.Substring(result.Length - 1);
			string lastTwoChars = result.Substring(result.Length - 2);
			string lastTrheeChars = result.Substring(result.Length - 3);
			string lastFourChars = result.Substring(result.Length - 4);

			// некоторые фамилии не склоняются в принципе, поэтому их сразу пролетаем

			// 1. Не склоняются: пишущиеся с О,Е,Э,И,Ы,У,Ю на конце
			if (Regex.IsMatch(lastOneChar, @"^[оеэиыую]{1}$"))
			{
				return result;
			}

			// 2. Не склоняются: оканчивающиеся на -а, -я с предшествующими гласным -и -у
			if (Regex.IsMatch(lastTwoChars, @"иа|уа|ия|уя$"))
			{
				return result;
			}

			// 3. Не склоняются: оканчивающиеся на -их -ых
			if (Regex.IsMatch(lastTwoChars, @"их|ых$"))
			{
				return result;
			}

			// склонения

			if (declineCase == "р")
			{
				if (gender == "male")
				{

					if (Regex.IsMatch(lastFourChars, @"убей|вбей$")) { return result.Substring(0, result.Length - 2) + "ея"; }  // Кочубей
					if (Regex.IsMatch(lastTrheeChars, @"оец|иец|еец|аец$")) { return result.Substring(0, result.Length - 2) + "йца"; }
					if (Regex.IsMatch(lastTrheeChars, @"нец|вец|жец|мец|бец|рец|пец|тец|шец$"))
					{
						if (Regex.IsMatch(result.Substring(result.Length - 3, 1), @"^[оеэиыую]{1}$"))
						{
							return result.Substring(0, result.Length - 2) + "ца"; // вариант с "беглой" гласной
						}
						return result.Substring(0, result.Length - 2) + "еца";
					}
					if (lastTrheeChars == "лец") { return result.Substring(0, result.Length - 3) + "льца"; }
					if (Regex.IsMatch(lastTrheeChars, @"лой|цой|гой|дой|рой|бой$")) { return result.Substring(0, result.Length - 2) + "оя"; } // Козодой, Рой
					if (Regex.IsMatch(lastTrheeChars, @"вей|бей$") && result.Length != 3) { return result.Substring(0, result.Length - 2) + "оя"; } // Воробей
					if (Regex.IsMatch(lastTrheeChars, @"ний|чий|сий|бий|дий|тий|лий|мий|жий|ший|щий|зий|рий|цый|вий|ций$")) { return result.Substring(0, result.Length - 2) + "его"; } // Бабий
					if (Regex.IsMatch(lastTwoChars, @"ня|ля|ря|дя|зя|тя$")) { return result.Substring(0, result.Length - 1) + "и"; } // Быконя
					if (Regex.IsMatch(lastTwoChars, @"ия$")) { return result.Substring(0, result.Length - 2) + "ии"; } // Абрамия
					if (Regex.IsMatch(lastTwoChars, @"ый|ий|ой$")) { return result.Substring(0, result.Length - 2) + "ого"; } // Андриевский
					if (Regex.IsMatch(lastOneChar, @"йь$")) { return result.Substring(0, result.Length - 1) + "я"; } // Брель

					if (!Regex.IsMatch(lastOneChar, @"[уеыаоэяий]{1}$")) { return result + "а"; } // оканчивающиеся на согласные
					if (lastOneChar == "а")
					{
						if (Regex.IsMatch(lastTwoChars, @"га|ка|ха|ча|ша|ща|жа$"))
						{
							return result.Substring(0, result.Length - 1) + "и";
						}
					}
				}

				if (gender == "female")
				{
					if (Regex.IsMatch(lastTrheeChars, @"ова|ева$"))
					{
						if (result.Length == 4 && (Regex.IsMatch(result.Substring(result.Length - 3, 1), @"^[уеыаоэяий]{1}$")))
						{
							return result.Substring(0, result.Length - 1) + "ы"; // если перед этим сочетанием всего одна согласная (например, Рева), то меняем на -ы
						}
						return result.Substring(0, result.Length - 1) + "ой"; // Иванова
					}
					if (Regex.IsMatch(lastTrheeChars, @"шна|ена|уна|ана$")) { return result.Substring(0, result.Length - 2) + "ны"; }
					if (lastTwoChars == "ая")
					{
						if (Regex.IsMatch(result.Substring(result.Length - 2, 1), @"^[цчшщж]{1}$"))
						{
							return result.Substring(0, result.Length - 2) + "ей";
						} else
						{
							return result.Substring(0, result.Length - 2) + "ой";
						}
					}
					if (Regex.IsMatch(lastTwoChars, @"яя$")) { return result.Substring(0, result.Length - 2) + "ей"; }
					if (Regex.IsMatch(lastTwoChars, @"ия$")) { return result.Substring(0, result.Length - 2) + "ии"; }
					if (Regex.IsMatch(lastTwoChars, @"ея$")) { return result.Substring(0, result.Length - 2) + "еи"; }
					if (Regex.IsMatch(lastTwoChars, @"ра|та|да|ба|са|ва|за|ма|ла|ца|па|фа$")) { return result.Substring(0, result.Length - 1) + "ы"; } // Звенигора
					if (Regex.IsMatch(lastTwoChars, @"ря|ля|ня|дя|зя|ья|тя|ся$")) { return result.Substring(0, result.Length - 1) + "и"; } // Зозуля
					if (Regex.IsMatch(lastTwoChars, @"га|ка|ха|ча|ша|ща|жа$"))
					{
						return result.Substring(0, result.Length - 1) + "и";
					}
				}
			}

			return result;
		}

	}
}