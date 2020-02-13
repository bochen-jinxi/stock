using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReadLine
{
    class Program
    {
        static void Main(string[] args)
        {
            FileStream fileStream = new FileStream(@"C:\自选股.EBK", FileMode.OpenOrCreate);
           
            var sr= EIIP.Helper.FileHelper.OpenStream(fileStream, Encoding.UTF8, Encoding.UTF8);
             
            string c = null;
            while ((c=sr.ReadLine())!=null)
            {
              
                EIIP.Helper.FileHelper.WriteLine(@"C:\code.txt",c.Length>0?c.ToString().Substring(1,6):"");
            }

            fileStream.Close();



        }
    }
}
