using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using EIIP.Helper;

namespace Stock获取价格
{
    internal class Program
    {

        // private static readonly StringBuilder sb = new StringBuilder(5000000);

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
                        // sb.AppendFormat("{0}/r/n", code);
                        return null;
                    }
                    if (we.Status == WebExceptionStatus.Timeout)
                    {
                        Thread.Sleep(5);
                        continue;
                    }
                }
                finally
                {
                }
                return null;
            }
        }

        private static void SetpOne(string n)
        {
            var url = ConfigurationSettings.AppSettings["URL" + n];

            var file = ConfigurationSettings.AppSettings["file" + n];
            FileStream fileStream = new FileStream(file, FileMode.OpenOrCreate);

            var sr = EIIP.Helper.FileHelper.OpenStream(fileStream, Encoding.UTF8, Encoding.UTF8);

            string c = null;
            int i = 0;
            while ((c = sr.ReadLine()) != null)
            {
                i++;
                //  EIIP.Helper.FileHelper.WriteLine(@"C:\code2.txt", c.Length == 6 ? string.Concat("\"", c, "\"", ",") : string.Concat("\"", c.PadLeft(6, '0'), "\"", ","));


                //for (var i = 0; i < One.Count; i++)
                //{
                var code = c.Trim();
                // var code = "300127";


                try
                {

                    var responseHTML = Reader(string.Format(url, code), code, true);
                    if (responseHTML.Length < 100) continue;

                    var datas = Newtonsoft.Json.JsonConvert.DeserializeObject<Data[]>(responseHTML);
                    var obj = datas[0];
                    if (n == "2" && code == "000001")
                    {
                        code = "999999";
                    }

                    for (int j = 0; j < obj.hq.Length; j++)
                    {
                        var a0 = obj.hq[j][0];
                        var a1 = obj.hq[j][1];
                        var a2 = obj.hq[j][2];
                        var a3 = obj.hq[j][3];
                        var a4 = obj.hq[j][4];
                        var a5 = obj.hq[j][5];
                        var a6 = obj.hq[j][6];
                        var a7 = obj.hq[j][7];
                        var a8 = obj.hq[j][8];
                        var a9 = obj.hq[j][9];

                        sb2.AppendFormat(@";INSERT INTO dbo.lishijiage (code,riqi,kai,shou,di,gao,chengjiaoliang) VALUES ('{0}', '{1}','{2}',N'{3}',N'{4}',N'{5}',N'{6}')", code, a0, a1, a2, a5, a6, a8);
                    }


                }

                finally
                {
                    Console.WriteLine(string.Concat(code, "=>", i));
                }



                //if (i>0&&i%10==0)
                //{
                FileHelper.WriteLine(@"c:/" + i + ".sql", sb2.ToString());
                sb2.Clear();
                //}
            }



        }
    }

    public class Data
    {

        public string[][] hq { get; set; }
        public string[] stat { get; set; }
        public string status { get; set; }

    }

}
