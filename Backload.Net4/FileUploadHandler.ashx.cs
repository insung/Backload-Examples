using Backload.Context.DataProvider;
using Backload.Contracts.Context;
using Backload.Contracts.FileHandler;
using Backload.Helper;
using System;
using System.Web;

namespace Backload.Net4
{
  /// <summary>
  /// FileUploadHandler의 요약 설명입니다.
  /// </summary>
  public class FileUploadHandler : IHttpHandler
  {

    public void ProcessRequest(HttpContext context)
    {
      try
      {
        // Wrap the request into a HttpRequestBase type
        //HttpRequestBase request = new HttpRequestWrapper(context.Request);
        BackloadDataProvider provider = new BackloadDataProvider(context.Request);

        // file rename
        if (context.Request.HttpMethod.Equals("POST"))
        {
          var name = provider.Files[0].FileName;
          provider.Files[0].FileName = string.Format("{0}_{1}", Guid.NewGuid(), name);
        }

        // Create and initialize the handler
        IFileHandler handler = Backload.FileHandler.Create();

        handler.Events.StoreFileRequestFinished += Event_IncomingRequestStarted;

        // Init Backload execution environment and execute the request
        handler.Init(provider);

        // Call the execution pipeline and get the result
        IBackloadResult result = handler.Execute().Result;

        // Write result to the response and flush
        ResultCreator.Write(context.Response, result);
        context.Response.Flush();
      }
      catch (Exception ex)
      {
        context.Response.StatusCode = 500;
        context.Response.StatusDescription = ex.Message;
      }
    }

    public bool IsReusable
    {
      get
      {
        return false;
      }
    }

    /// <summary>
    /// custom event
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void Event_IncomingRequestStarted(IFileHandler sender, Backload.Contracts.Eventing.IStoreFileRequestEventArgs e)
    {
      e.Param.FileStatusItem.Message = "(test) ";
    }
  }
}