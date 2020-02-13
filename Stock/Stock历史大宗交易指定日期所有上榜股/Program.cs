using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using EIIP.Helper;
using Newtonsoft.Json;

namespace Stock历史大宗交易指定日期所有上榜股
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


        private static readonly string url = "http://page.tdx.com.cn:7615/TQLEX?Entry=CWServ.SecuInfo";
        private static int count;

        private static void Main(string[] args)
        {
            Console.WriteLine("先输入start运行，直到看到over后，输入continue继续，直到看到over输入end结束！");
            Console.ReadLine();

            var dt = Convert.ToDateTime(ConfigurationSettings.AppSettings["dt"]);

            var dt2 = Convert.ToDateTime(ConfigurationSettings.AppSettings["dt2"]);

            var ts = dt2 - dt;
            var days = (int) ts.TotalDays;

            for (var i = 0; i <= days; i++)
            {
                try
                {
                    SetpOne(dt.ToString("yyyyMMdd"));
                }
                catch (Exception ex)
                {
                    FileHelper.WriteLine(@"C:/LSDZJYException.txt",dt.ToString("yyyyMMdd"));
                }


                dt = dt.AddDays(1);
            }
        }


        private static void SetpOne(string dt)
        {
            var param = new List<string> {"1", dt};
            var li = new RequiredData {CallName = "f10_zs_dzjy", Params = param};
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
                        sb.AppendFormat(@";INSERT INTO dbo.lishidazongjiaoyi
                            ( code, name, CTime,cjj,cjje,cjl,buy,sale,sc )
                    VALUES  ( '{0}', 
                              '{1}', 
                              '{2}',
                              N'{3}',  
                                N'{4}',
                                N'{5}',
                                 N'{6}',  
                                N'{7}',
                                 N'{8}'
                              )", l[i][0], l[i][1], l[i][2], l[i][3], l[i][4], l[i][5], l[i][6], l[i][7], l[i][8]);


                        count++;


                        Console.WriteLine(dt + "_" + l[i][0]);


                        //if (count > 0 && count%10 == 0)
                        //{
                            FileHelper.WriteLine(@"c:/dzjy" + count + ".sql", sb.ToString());
                            sb.Clear();
                        //}
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
                request.ContentType = "application/x-www-form-urlencoded; charset=UTF-8";
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
                    Thread.Sleep(1000*20);
                }
            }
        }
    }
}