using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using EIIP.Helper;
using Newtonsoft.Json;

namespace Stock历史龙虎榜指定日期单只上榜股异常处理
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



            FileStream fileStream = new FileStream(@"C:\LSLHB2.txt", FileMode.OpenOrCreate);

            var sr = EIIP.Helper.FileHelper.OpenStream(fileStream, Encoding.UTF8, Encoding.UTF8);

            string c = null;
            while ((c = sr.ReadLine()) != null)
            {
                if (string.IsNullOrEmpty(c)) continue;
                try
                {
                    SetpTwo(c.Split('_')[0], c.Split('_')[1]);
                }
                catch (Exception ex)
                {
                    FileHelper.WriteLine(@"C:/LSLHBException3.txt",
                        ex.Message + "_" + c.Split('_')[0] + "_" + c.Split('_')[1] + ex.StackTrace);
                }

            }

            fileStream.Close();
        }

        private static void SetpTwo(string dt, string code)
        {

            var param = new List<string>() { "2", dt, code };
            var li = new RequiredData() { CallName = "f10_zs_jylhb", Params = param, };

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
                Dictionary<string, string> dic = new Dictionary<string, string>();
                for (int i = 0; i < l.Length; i++)
                {

                    //if (l[i][6].ToString().Contains("三个"))
                    //{
                    //    continue;
                    //}



                    if (!dic.ContainsKey(l[i][1] + l[i][2] + l[i][3]))
                    {
                        dic.Add(l[i][1] + l[i][2] + l[i][3], l[i][1] + l[i][2] + "_" + l[i][3] + "_" + l[i][6]);

                    }
                }


                foreach (var kv in dic)
                {
                    sb.AppendFormat(@";INSERT INTO dbo.lishilonghubang
                            ( code, CTime,Trade,[Percent],Sales,content )
                    VALUES  ( '{0}', 
                              '{1}', 
                              '{2}',
                              N'{3}',  
                                N'{4}',
                                N'{5}'
                              )", code, dt, kv.Value.Split('_')[0], "_", kv.Value.Split('_')[1], kv.Value.Split('_')[2]);


                }
                count++;








                Console.WriteLine(dt + code);


             
                    FileHelper.WriteLine(@"c:/" + count + ".sql", sb.ToString());
                    sb.Clear();
               









            }



        }


        private static string Reader(string url, string data)
        {
            while (true)
            {
                var request = (HttpWebRequest)WebRequest.Create(url);
                request.ContentType = "application/json; charset=utf-8";
                request.Method = "POST";
                request.Headers.Set("Accept-Language", "zh-CN");
                request.Credentials = CredentialCache.DefaultCredentials;
                request.Timeout = 1000 * 1;
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
                    var httpResponse = (HttpWebResponse)request.GetResponse();
                    using (
                        var streamReader = new StreamReader(httpResponse.GetResponseStream(),
                            Encoding.GetEncoding("utf-8")))
                    {
                        return streamReader.ReadToEnd();
                    }
                }
                catch (Exception ex)
                {
                    Thread.Sleep(1000 * 5);
                }
            }
        }
    }
}