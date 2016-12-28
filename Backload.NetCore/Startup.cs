using Backload.MiddleWare;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace BackloadService
{
    public class Startup
    {
        public Startup(IHostingEnvironment env)
        {
            // How to appsettings.json configurations
            // references source code https://github.com/aspnet/docs/tree/master/aspnetcore/fundamentals/configuration/sample
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();

            Configuration = builder.Build();
        }

        public IConfigurationRoot Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit http://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<BackloadService.Code.Settings>(Configuration.GetSection("AppSettings"));

            // file upload size limit 2GB
            // references https://forums.asp.net/t/2100265.aspx?How+to+increase+upload+file+size+in+ASP+Net+Core
            services.Configure<FormOptions>(option => 
            {
                option.MultipartBodyLengthLimit = 2147483648;
            });

            services.AddMvc();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, ILoggerFactory loggerFactory)
        {
            app.UseStaticFiles();

            // The following code shows how to add an internal handler as middleware. 
            // If you use a custom controller (e.g. custom events demo) you can remove this code

            // Method 1: Simple call to add the internal handler without logging or routing
            // app.UseBackload();

            // Method 2: Add logging (console logger)
            loggerFactory.AddConsole(LogLevel.Error);
            var logger = loggerFactory.CreateLogger("Backload");
            app.UseBackload(
                log =>
                {
                    log.SetLogging(logger, LogLevel.Error);
                });

            // Method 3: Call internal handler only if path contains /Backload/FileHandler
            // app.MapWhen(
            //    context => context.Request.Path.Value.Contains("/Backload/FileHandler"),
            //    appBranch =>
            //    {
            //        appBranch.UseBackload();
            //    });


            app.UseMvc(routes =>
            {
                routes.MapRoute(
                    name: "default",
                    template: "{controller=Backload}/{action=Index}/{id?}");
            });
        }
    }
}
