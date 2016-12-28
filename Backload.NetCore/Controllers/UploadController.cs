
using System.Threading.Tasks;
using Backload.Context.DataProvider;
using Backload.Contracts.Context;
using Backload.Contracts.FileHandler;
using BackloadService.Helper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using System;
using System.IO;

namespace BackloadService
{
    public class UploadController : Controller
    {
        private IHostingEnvironment _hosting;

        private readonly IOptions<BackloadService.Code.Settings> _config;

        // Constructor
        public UploadController(IHostingEnvironment hosting, IOptions<BackloadService.Code.Settings> config)
        {
            _hosting = hosting;
            _config = config;
        }

        // The Backload file handler. 
        // To access it in an JavaScript AJAX request use: <code>var url = "/Backload/FileHandler/";
        public async Task<ActionResult> FileHandler()
        {
            try
            {                
                using (var provider = new BackloadDataProvider(this.HttpContext, _hosting))
                {
                    if (this.HttpContext.Request.Method == "POST")
                    {
                        var name = provider.Files[0].FileName;
                        provider.Files[0].FileName = string.Format("{0}_{1}", Guid.NewGuid(), name);
                    }

                    // Create and initialize the handler
                    IFileHandler handler = Backload.FileHandler.Create();

                    // Attach event handlers to events
                    handler.Events.PreInitialization += Events_PreInitialization;
                    handler.Events.StoreFileRequestFinished += Events_StoreFileFinished;

                    // Init Backloads execution environment and execute the request
                    handler.Init(provider);
                    IBackloadResult result = await handler.Execute();

                    // Helper to create an ActionResult object from the IBackloadResult instance
                    return ResultCreator.Create(result);
                }
            }
            catch
            {
                return new StatusCodeResult(500);
            }
        }

        // SecureStream Init
        void Events_PreInitialization(IFileHandler sender, Backload.Contracts.Eventing.IPreInitializationEventArgs e)
        {
            
        }

        // Get Document Group
        private void Events_StoreFileFinished(IFileHandler sender, Backload.Contracts.Eventing.IStoreFileRequestEventArgs e)
        {
            try
            {
                // get exportdata from appsettings.json
                string exportDataPath = _config.Value.ExportDataPath;

                Random rand = new Random();
                int groupId = rand.Next(1, 3);
                e.Param.FileStatusItem.Message = groupId.ToString();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
}