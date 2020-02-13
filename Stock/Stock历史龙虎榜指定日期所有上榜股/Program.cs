using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using EIIP.Helper;
using Newtonsoft.Json;

namespace Stock历史龙虎榜指定日期所有上榜股
{
    public class RequiredData
    {
        public string CallName { get; set; }
        public List<string> Params { get; set; }
    }


    public class ResponseData
    {
        public List<ResultSets> ResultSets { get; set; }
        public int ErrorCode { get; set; }
        public int ResultSetNum { get; set; }
    }

    public class ResultSets
    {
        public List<ColDes> ColDes { get; set; }
        public string[][] Content { get; set; }

        public int ColNum { get; set; }
        public int RowNum { get; set; }
    }

    public class ColDes
    {
        public string Name { get; set; }
    }


    internal class Program
    {
        private static readonly StringBuilder sb = new StringBuilder(500);

      
         private static string url = "http://page.tdx.com.cn:7615/TQLEX?Entry=CWServ.SecuInfo ";
        private static int count = 0;
        private static void Main(string[] args)
        {
            Console.WriteLine("先输入start运行，直到看到over后，输入continue继续，直到看到over输入end结束！");
            Console.ReadLine();

            var dt = Convert.ToDateTime(ConfigurationSettings.AppSettings["dt"]);
            //var dt = new DateTime(2017, 11, 22);
            var dt2 = Convert.ToDateTime(ConfigurationSettings.AppSettings["dt2"]);

            var ts = dt2 - dt;
            var days = (int)ts.TotalDays;

            for (var i = 0; i <= days; i++)
            {
                try
                {
                    SetpOne(dt.ToString("yyyyMMdd"));
                }
                catch (Exception ex)
                {
                    FileHelper.WriteLine(@"C:/LSLHBException.txt",
                        ex.Message + "_" + dt.ToString("yyyyMMdd") + ex.StackTrace);
                }


                dt = dt.AddDays(1);
            }




        }

       
        private static void SetpOne(string dt)
        {
            
            var param = new List<string> {"1", dt, ""};
            var li = new RequiredData {CallName = "f10_zs_jylhb", Params = param};
            var data = JsonConvert.SerializeObject(li);

            var responsedata = Reader(url, data);
            var el = JsonConvert.DeserializeObject<ResponseData>(responsedata);

            foreach (var e in el.ResultSets)
            {
                if (e.RowNum == 0)
                {
                    continue;
                }
                var l = e.Content;
                for (var i = 0; i < l.Length; i++)
                {
                    if (l.Length > 1)
                    {
                        FileHelper.WriteLine(@"c:/LSLHB.txt", dt + "_" + l[i][0]);
                    }
                }
            }


            Console.WriteLine("所有上榜 \n" + data);
        }

        private static string Reader(string url, string data)
        {
            while (true)
            {
                var request = (HttpWebRequest) WebRequest.Create(url);
                request.ContentType = "application/json; charset=utf-8";
                request.Method = "POST";
                request.Headers.Set("Accept-Language", "zh-CN");
                request.Credentials = CredentialCache.DefaultCredentials;
                request.Timeout = 1000*1;
                request.ServicePoint.ConnectionLimit = 1000;


                using (var streamWriter = new StreamWriter(request.GetRequestStream()))
                {
                    // string json = "{\"CallName\":\"f10_zs_jylhb\",\"Params\":[\"1\",\"20171124\",\"\"]}";
                    var json = data;
                    streamWriter.Write(json);
                    streamWriter.Flush();
                }
                try
                {
                    var httpResponse = (HttpWebResponse) request.GetResponse();
                    using (
                        var streamReader = new StreamReader(httpResponse.GetResponseStream(),
                            Encoding.GetEncoding("utf-8")))
                    {
                        return streamReader.ReadToEnd();
                    }
                }
                catch (Exception ex)
                {
                    Thread.Sleep(1000*5);
                }
            }
        }
    }
}