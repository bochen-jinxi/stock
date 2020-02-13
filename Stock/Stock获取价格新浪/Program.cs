using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using EIIP.Helper;

namespace Stock获取价格新浪
{
    internal class Program
    {

     
        private static readonly StringBuilder sb2 = new StringBuilder(5000000);
    

        private static void Main(string[] args)
        {
            Console.WriteLine("先输入start运行，直到看到over后，输入continue继续，直到看到over输入end结束！");
            var param = Console.ReadLine();



            SetpOne(param);



        }

        private static string Reader(string url, string code, bool iscx)
        {
            while (true)
            {
                Thread.Sleep(1000 * 1);
                try
                {
                    var request = (HttpWebRequest)WebRequest.Create(url);
                    request.ContentType = "application/x-www-form-urlencoded";
                    request.Method = "get";
                    request.Headers.Set("Accept-Language", "gb2312");
                    request.Credentials = CredentialCache.DefaultCredentials;
                    request.Timeout = 1000 * 1;
                    request.ServicePoint.ConnectionLimit = 1000;
                    var response = (HttpWebResponse)request.GetResponse();
                    var reader = new StreamReader(response.GetResponseStream(), Encoding.GetEncoding("gb2312"));
                    return reader.ReadToEnd();
                }
                catch (WebException we)
                {
                    if (we.Status == WebExceptionStatus.ProtocolError && iscx)
                    {
                        Thread.Sleep(1000 * 60 * 5);
                        continue;
                        //return null;
                    }
                    if (we.Status == WebExceptionStatus.Timeout)
                    {
                        Thread.Sleep(1000*5);
                        continue;
                    }
                }
                finally
                {
                }
                return null;
            }
        }

        private static void SetpOne(string n )
        {
            var url = ConfigurationSettings.AppSettings["URL"+n];
            //url = "http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/399106/type/S.phtml?year=2018&jidu=1";
            var file = ConfigurationSettings.AppSettings["file"+ n];
            FileStream fileStream = new FileStream(file, FileMode.OpenOrCreate);

            var sr = EIIP.Helper.FileHelper.OpenStream(fileStream, Encoding.UTF8, Encoding.UTF8);

            string c = null;
            int i = 0;
            while ((c = sr.ReadLine()) != null)
            {
                i++;
                List<Data> list = new List<Data>();

        //  EIIP.Helper.FileHelper.WriteLine(@"C:\code2.txt", c.Length == 6 ? string.Concat("\"", c, "\"", ",") : string.Concat("\"", c.PadLeft(6, '0'), "\"", ","));


        //for (var i = 0; i < One.Count; i++)
        //{
        var code = c.Trim();
                // code = "002357";


                

                

                    var responseHTML = Reader(string.Format(url, code), code, true);

                    Match matchResults = null;
                    
                        matchResults = Regex.Match(responseHTML, @"<table id=""FundHoldSharesTable"">([\s\S])*</table>");
                        if (matchResults.Success)
                        {
                    try
                    {
                        //取一
                        var str = matchResults.Value;
                        str = str.Replace("class=\"tr_2\"", "");

                            Match matchResults2 = null;

                    matchResults2 = Regex.Match(str, @"<tr >[\s\S]+?</tr>");
                        int count2 = 1;
                        while (matchResults2.Success)
                            {
                           
                            if (count2 == 1) {
                                matchResults2 = matchResults2.NextMatch();
                                count2++; continue;
                            } 
                            //取二
                            var str2 = matchResults2.Value;

                            Regex r = new Regex(@"\s(\d{4}-\d{2}-\d{2})", RegexOptions.None);
                            Match mc = r.Match(str2);
                            string riqiStr = mc.Groups[1].Value;

                            str2 = Regex.Replace(str2, @"<a(.*)\s+(.*)</a>", string.Format("{0}", riqiStr));


                            Regex regexObj = new Regex(@"<td([^>]+)?><div align=""center"">(\s+)?(.*)(\s+)?</div>");
                            Match matchResult = regexObj.Match(str2);
                           var  oData=new Data();
                                int count = 1;
                            while (matchResult.Success)
                            {
                               //取三
                                var gupiaoneirong=matchResult.Groups[3].Value;
                                switch (count)
                                {
                                    case 1:
                                        oData.riqi = gupiaoneirong.Replace("\r","");
                                        break;
                                    case 2:
                                        oData.kai = gupiaoneirong;
                                        break;
                                    case 3:
                                        oData.gao = gupiaoneirong;
                                        break;
                                    case 4:
                                        oData.shou = gupiaoneirong;
                                        break;
                                    case 5:
                                        oData.di = gupiaoneirong;
                                        break;
                                    case 7:
                                        oData.chengjiaoliang = Math.Round((Convert.ToDecimal(gupiaoneirong) / 10000), 2).ToString();
                                        break;

                                }
                               
                                //Console.WriteLine(gupiaoneirong);
                                matchResult = matchResult.NextMatch();
                                count++;
                            }
                                if (n == "2"&&code=="000001")
                                {
                                    code = "999999";
                                }
                                oData.code = code;
                            list.Add(oData);
                          //  Console.WriteLine(str2);
                            matchResults2 = matchResults2.NextMatch();
                                count2++;
                            }





                        var riqi1 = ConfigurationSettings.AppSettings["fileriqi1"];
                        var riqi2 = ConfigurationSettings.AppSettings["fileriqi2"];
                        var riqi3 = ConfigurationSettings.AppSettings["fileriqi3"];
                        var riqi4 = ConfigurationSettings.AppSettings["fileriqi4"];
                        var riqi5 = ConfigurationSettings.AppSettings["fileriqi5"];
                        var riqi6 = ConfigurationSettings.AppSettings["fileriqi6"];
                        var riqi7 = ConfigurationSettings.AppSettings["fileriqi7"];
                        var riqi8 = ConfigurationSettings.AppSettings["fileriqi8"];
                        var riqi9 = ConfigurationSettings.AppSettings["fileriqi9"];

                        var list2 =
                            list.Where(
                                a =>
                                a.riqi.Equals(riqi1) ||
                                 a.riqi.Equals(riqi2) ||
                                  a.riqi.Equals(riqi3) ||
                                   a.riqi.Equals(riqi4) ||
                                    a.riqi.Equals(riqi5) ||
                                     a.riqi.Equals(riqi6) ||
                                      a.riqi.Equals(riqi7) ||
                                       a.riqi.Equals(riqi8) ||
                                        a.riqi.Equals(riqi9)

                             ).ToList();

                        foreach (var el in list2)
                        {
                            sb2.AppendFormat(@";INSERT  INTO dbo.lishijiage
                                ( code ,
                                  riqi ,
                                  kai ,
                                  shou ,
                                  di ,
                                  gao,
                                  chengjiaoliang
                                )
                        VALUES  ( '{0}' ,
                                  '{1}' ,
                                  '{2}' ,
                                  N'{3}' ,
                                  N'{4}' ,
                                  N'{5}',
                                  N'{6}'
                                )", el.code, el.riqi, el.kai, el.shou, el.di, el.gao,el.chengjiaoliang);
                        }

                       
                       

                    }

                    finally
                {
                    Console.WriteLine(string.Concat(code, "=>", i));
                }



                    if (sb2.Length>0)
                    {
                        FileHelper.WriteLine(@"c:/" + i + ".sql", sb2.ToString());
                        sb2.Clear();

                    }
                }



        }
    }
    public class Data
    {

      
       
          

        public string code { get; set; }
        public string riqi { get; set; }
        public string kai { get; set; }
        public string shou { get; set; }
        public string di { get; set; }
        public string gao { get; set; }
        public string chengjiaoliang { get; set; }

        }

}
    }
