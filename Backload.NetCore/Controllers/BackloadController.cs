using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;

namespace BackloadService
{
    public class BackloadController : Controller
    {
        private static int fileCount = 0;

        private static List<KeyValuePair<int, string>> docGroupList;

        // Index Page
        public IActionResult Index()
        {
            ViewBag.TempDir = Guid.NewGuid().ToString();
            ViewBag.MaxSize = 1073741824; // 1GB
            ViewBag.MaxCount = 10;

            docGroupList  = new List<KeyValuePair<int, string>>();

            docGroupList.Add(new KeyValuePair<int, string>(1, "random 1"));
            docGroupList.Add(new KeyValuePair<int, string>(2, "random 2"));
            docGroupList.Add(new KeyValuePair<int, string>(3, "random 3"));

            return View();
        }

        // Index Page
        public IActionResult Index2(string tempDirectory, int maxFileSize, int maxFileCount, string groups, string scexport)
        {
            ViewBag.TempDir = tempDirectory;
            ViewBag.MaxSize = maxFileSize;
            ViewBag.MaxCount = maxFileCount;

            docGroupList  = new List<KeyValuePair<int, string>>();

            // group list 는 id|name,id|name 으로 넘어옴
            foreach (var item in groups.Split('|'))
            {
                if (!string.IsNullOrEmpty(item))
                {
                    int startIndex = item.IndexOf('(');
                    int endIndex = item.IndexOf(')') + 1;
                    int length = endIndex - startIndex;

                    string groupId = item.Substring(startIndex, length);
                    string groupName = item.Substring(endIndex);

                    docGroupList.Add(new KeyValuePair<int, string>(Convert.ToInt32(groupId.Replace("(", "").Replace(")", "").Trim()), groupName.Trim()));
                }
            }

            return View();
        }

        // Set Attached File Count
        [HttpPostAttribute]
        public void SetAttachedFileCount(string value)
        {
            fileCount = Convert.ToInt32(value);
        }

        // Get Attached File Count
        [HttpGetAttribute]
        public string GetAttachedFileCount()
        {
            return fileCount.ToString();
        }

        [HttpPostAttribute]
        public JsonResult GetDocGroupList()
        {
            return Json(docGroupList);
        }
    }
}