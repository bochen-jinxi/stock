using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using EIIP.Helper;
using Newtonsoft.Json;

namespace Stock季报
{
    public class RequiredData
    {
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
        private static readonly StringBuilder sb2 = new StringBuilder(500);
        private static readonly StringBuilder sb90 = new StringBuilder(500);
        private static readonly StringBuilder sb3 = new StringBuilder(500);
        private static readonly StringBuilder sb903 = new StringBuilder(500);


        private static readonly string url = "http://page.tdx.com.cn:7615/TQLEX?Entry=CWServ.tdxf10_gg_cwfx";
        private static int count2;

        private static void Main(string[] args)
        {
            Console.WriteLine("先输入start运行，直到看到over后，输入continue继续，直到看到over输入end结束！");
            Console.ReadLine();


             //SetpTwo("600733");
           // return;
            var fileStream = new FileStream(@"C:\can.txt", FileMode.OpenOrCreate);

            StreamReader sr = FileHelper.OpenStream(fileStream, Encoding.UTF8, Encoding.UTF8);


            string c = null;
            while ((c = sr.ReadLine()) != null)
            {
                if (string.IsNullOrEmpty(c)) continue;
                try
                {
                    SetpTwo(c);
                }
                catch (Exception ex)
                {
                    FileHelper.WriteLine(@"C:/canException.txt", c);
                }
            }

            fileStream.Close();
        }


        private static void SetpTwo(string code)
        {
            // {"Params":["600703","zyzb",""]}
            var param = new List<string> {code, "zyzb", ""};

            var li = new RequiredData {Params = param};
            string data = JsonConvert.SerializeObject(li);

            string responsedata = Reader(url, data);
            var el = JsonConvert.DeserializeObject<ResponseData>(responsedata);
            int count = 0;

            var dic = new Dictionary<string, List<string>>();
            var dic90 = new Dictionary<string, List<string>>();
            var list = new List<string>();
            var list90 = new List<string>();
            foreach (ResultSets e in el.ResultSets)
            {
                if (count == 1)
                {
                    int index = 0;
                    foreach (var element in e.Content)
                    {
                        //日期
                        string rq = element[0];
                        //每股收益
                        string mgsy = element[1];
                        //营业总收入
                        int length3 = el.ResultSets[3].Content.Length;
                        string yyzsr = "";
                        if (index < length3)
                        {
                            yyzsr = el.ResultSets[3].Content[index][1];
                        }

                        //营业同比增长率 
                        string yysrtb = element[12];


                        //净利润同比增长率 
                        string jlrtb = element[11];
                        //净利润总额
                        string jlr = element[8];

                        //扣非净利润
                        int length2 = el.ResultSets[2].Content.Length;
                        string kfjlr = "";
                        if (index < length2)
                        {
                            kfjlr = el.ResultSets[2].Content[index][1];
                        }


                        index++;
                        list.Add(rq);
                        list.Add(mgsy);
                        list.Add(yyzsr);
                        list.Add(kfjlr);
                        list.Add(jlr);
                        list90.Add(rq);
                        list90.Add(yysrtb);
                        list90.Add(jlrtb);
                     
                    }

                    dic90.Add(code, list90);
                    dic.Add(code, list);
                }
                count++;
            }


            foreach (var kv90 in dic90)
            {
                List<string> listtb = kv90.Value;
                for (int j = 0; j < 300; j++)
                {
                    sb90.Append(string.Format("tb{0},", j));
                }

                for (int i = 0; i < listtb.Count; i++)
                {
                    sb903.Append(string.Format("'{0}',", listtb[i]));
                }
                if (300 - listtb.Count > 0)
                {
                    for (int i = listtb.Count; i < 300; i++)
                    {
                            sb903.Append(string.Format("'{0}',", "")); 
                    }
                }
            }

            foreach (var kv in dic)
            {
                List<string> list2 = kv.Value;
                for (int i = 0; i < 300; i++)
                {
                    sb2.Append(string.Format("C{0},", i));
                }

                for (int i = 0; i < list2.Count; i++)
                {
                    sb3.Append(string.Format("'{0}',", list2[i]));
                }
                if (300 - list2.Count > 0)
                {
                    for (int i = list2.Count; i < 300; i++)
                    {
                       
                        
                            sb3.Append(string.Format("'{0}',", ""));
                        
                    }
                }


               

               // sb2.Length--;
               // sb3.Length--;
                sb90.Length--;
                sb903.Length--;
                sb.AppendFormat(@";INSERT INTO can
                            (code, {0}{3})
                    VALUES  ({2}, {1}{4})", sb2, sb3, string.Format("'{0}'", kv.Key), sb90.ToString(),sb903.ToString());


                count2++;


                Console.WriteLine(kv.Key);


                if (count2 > 0)
                {
                    FileHelper.WriteLine(@"c:/can" + count2 + ".sql", sb.ToString());
                    sb.Clear();
                    sb2.Clear();
                    sb3.Clear();
                    sb90.Clear();
                    sb903.Clear();
                }
            }


            Console.WriteLine("所有上榜 \n" + data);
        }

        private static string Reader(string url, string data)
        {
            while (true)
            {
                Thread.Sleep(500);
                var request = (HttpWebRequest) WebRequest.Create(url);
                request.ContentType = "application/x-www-form-urlencoded; charset=UTF-8";
                request.Method = "POST";
                request.Headers.Set("Accept-Language", "zh-CN");
                // request.Credentials = CredentialCache.DefaultCredentials;
                // request.Timeout = 1000 * 1;
                // request.ServicePoint.ConnectionLimit = 1000;


                using (var streamWriter = new StreamWriter(request.GetRequestStream()))
                {
                    // string json = "{"Params":["600703","zyzb",""]}";
                    string json = data;
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
                    Thread.Sleep(1000*10);
                }
            }
        }
    }
}