using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using EIIP.Helper;

namespace Stock流通股东_StockHolder
{


    class Program
    {
        
        private  static int count = 0;
        #region 股票池

       
     
        #endregion

        static void Main(string[] args)
        {
            Console.WriteLine("先输入start运行，直到看到over后，输入continue继续，直到看到over输入end结束！");
            Console.ReadLine();

            var fileStream = new FileStream(@"C:\can.txt", FileMode.OpenOrCreate);

            StreamReader sr = FileHelper.OpenStream(fileStream, Encoding.UTF8, Encoding.UTF8);


            string c = null;
            while ((c = sr.ReadLine()) != null)
            {
                if (string.IsNullOrEmpty(c)) continue;
                try
                {
                    SetpOne(c);
                }
                catch (Exception ex)
                {
                    FileHelper.WriteLine(@"C:/10Exception.txt", c);
                }
            }

            fileStream.Close();
            
          

           // SetpOne(arrayStock);

        }


        private static void SetpOne(string code)
        {

                Dictionary<int,string> dic = new Dictionary<int, string>();
                     StringBuilder sb = new StringBuilder();
                 //var code = "600733";
                try
                {

                    var url = ConfigurationSettings.AppSettings["URL"];
                    string responseHTML =
                        new WebClient().DownloadString(string.Format(url,code));
                    var dt = DateTime.Now;
                    DateTime startQuarter = dt.AddMonths(0 - (dt.Month - 1) % 3).AddDays(1 - dt.Day);  //本季度初
                    DateTime endQuarter = startQuarter.AddDays(-1);  //上季度末

                    var eq = endQuarter.ToString("yyyy-MM-dd");


                    if (!Regex.IsMatch(responseHTML, eq))
                    {
                        return;
                    }
                    Match matchResults0 = null;
                    matchResults0 = Regex.Match(responseHTML, @"<div\s+\w+=""(.*)\s+id=""fher_\d(.*)>([\W\w]*?)</table>\s+</div>");
                 
                    for (int x = 0; x < 5; x++)
                    {

                        if (matchResults0.Success)
                        {
                            switch (x)
                            {
                                case 0:
                                    responseHTML = matchResults0.Value;
                                    break;
                                case 1:
                                    
                                    responseHTML = matchResults0.NextMatch().Value;
                                    break;
                                case 2:
                                   
                                    responseHTML = matchResults0.NextMatch().NextMatch().Value;
                                    break;
                                case 3:
                                   
                                    responseHTML = matchResults0.NextMatch().NextMatch().NextMatch().Value;
                                    break;
                                case 4:
                                 
                                    responseHTML = matchResults0.NextMatch().NextMatch().NextMatch().NextMatch().Value;
                                    break;
                            }


                            
                        Match matchResults = null;

                        matchResults = Regex.Match(responseHTML, "<a href=\"javascript:void(.*)>(.*)</a>");
                        if (matchResults.Success)
                        {
                            dic.Clear();
                            dic.Add(1,matchResults.Groups[2].Value);
                            dic.Add(2,matchResults.NextMatch().Groups[2].Value);
                            dic.Add(3,matchResults.NextMatch().NextMatch().Groups[2].Value);
                            dic.Add(4,matchResults.NextMatch().NextMatch().NextMatch().Groups[2].Value);
                            dic.Add(5,matchResults.NextMatch().NextMatch().NextMatch().NextMatch().Groups[2].Value);
                            dic.Add(6,matchResults.NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().Groups[2].Value);
                            dic.Add(7,matchResults.NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().Groups[2].Value);
                            dic.Add(8,matchResults.NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().Groups[2].Value);
                            dic.Add(9,matchResults.NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().Groups[2].Value);
                            dic.Add(10,matchResults.NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().NextMatch().Groups[2].Value);
                            for (int j = 0; j < dic.Values.Count; j++)
                            {
                                var name = dic.Values.ToList()[j];
                                  
                                var arr = name.Split('-');
                                var arrIndex = arr.Length;
                                string holderName1 = string.Empty; string holderName2 = string.Empty; string holderName3 = string.Empty; string holderName4 = string.Empty; string holderName5 = string.Empty;
                                string holderName10 = string.Empty; string holderName20 = string.Empty; string holderName30 = string.Empty; string holderName40 = string.Empty; string holderName50 = string.Empty;
                                switch (arrIndex)
                                {
                                    case 2:
                                        holderName1 = arr[1];
                                        holderName10 = GetValue(holderName1);
                                        break;
                                    case 3:
                                        holderName1 = arr[0];
                                        holderName2 = arr[1];
                                        holderName3 = arr[2];
                                        holderName10 = GetValue(holderName1);
                                        holderName20 = GetValue(holderName2);
                                        holderName30 = GetValue(holderName3);

                                        break;
                                    case 4:
                                        holderName1 = arr[0];
                                        holderName2 = arr[1];
                                        holderName3 = arr[2];
                                        holderName4 = arr[3];
                                        holderName10 = GetValue(holderName1);
                                        holderName20 = GetValue(holderName2);
                                        holderName30 = GetValue(holderName3);
                                        holderName40 = GetValue(holderName4);
                                        break;
                                    case 5:
                                        holderName1 = arr[0];
                                        holderName2 = arr[1];
                                        holderName3 = arr[2];
                                        holderName4 = arr[3];
                                        holderName5 = arr[4];
                                        holderName10 = GetValue(holderName1);
                                        holderName20 = GetValue(holderName2);
                                        holderName30 = GetValue(holderName3);
                                        holderName40 = GetValue(holderName4);
                                        holderName50 = GetValue(holderName5);
                                        break;


                                }

                                    string sql = @"INSERT INTO [StockHolder] ( 
[Code],
[HolderName],
[HolderName1],
[HolderName2],
[HolderName3],
[HolderName4],
[HolderName5],
[HolderName10],
[HolderName20],
[HolderName30],
[HolderName40],
[HolderName50],
[OrderID]

) VALUES (
'{0}',
'{1}',
'{2}',
'{3}',
'{4}',
'{5}',
'{6}',
'{7}',
'{8}',
'{9}',
'{10}',
'{11}',
'{12}'
);";

                                   var str= string.Format(sql, code, name, string.IsNullOrEmpty(holderName1)?"null":holderName1,
                                       string.IsNullOrEmpty(holderName2) ? "null" : holderName2,  
                                       string.IsNullOrEmpty(holderName3) ? "null" : holderName3,  
                                       string.IsNullOrEmpty(holderName4) ? "null" : holderName4,  
                                       string.IsNullOrEmpty(holderName5) ? "null" : holderName5,  
                                       string.IsNullOrEmpty(holderName10) ? "null" : holderName10, 
                                       string.IsNullOrEmpty(holderName20) ? "null" : holderName20, 
                                       string.IsNullOrEmpty(holderName30) ? "null" : holderName30, 
                                       string.IsNullOrEmpty(holderName40) ? "null" : holderName40, 
                                       string.IsNullOrEmpty(holderName50) ? "null" : holderName50, 
                                       j + 1);
                                    sb.Append(str);
                                dic.Clear();

                                
                            }

                        }
                    }


                    }
                    count++;
                    EIIP.Helper.FileHelper.WriteLine(@"c:/"+count+ ".sql", sb.ToString());
                    sb.Clear();
                }
                catch(Exception ex)
                {
                    
                }
                
                    Console.WriteLine(string.Concat(code, "=>", count.ToString()));
               
           
          
            

        }

        private static string GetValue(string holderName)
        {
            string tempHolderName = "";
            if (holderName.Contains("基金"))
            {
                tempHolderName = holderName.Substring(0, 2);
            }
            return tempHolderName;
        }

       



    }



}
