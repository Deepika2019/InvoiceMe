var defaultSettings = {
    // Data attributes
    headers: [],  // String[] - Array of column headers
    tasks: [],    // Task[] - Array of tasks. Required fields: 
    
    // id: number, startTime: number, duration: number, column: number
    //tasklist:[],
    // Card template - Inner content of task card. 
    // You're able to use ${key} inside template, where key is any property from task.
    cardTemplate: '<div>${id}</div>',

    // OnClick event handler
    onClick: function (e, task) { }, //alert(e); },

    // Css classes
    containerCssClass: 'skeduler-container',
    headerContainerCssClass: 'skeduler-headers',
    // dateContainerCssClass: 'skeduler-date',
    schedulerContainerCssClass: 'skeduler-main',
    taskPlaceholderCssClass: 'skeduler-task-placeholder',
    cellCssClass: 'skeduler-cell',
    titleClass: 'titleClass',

    // lineHeight: 30,      // height of one half-hour line in grid
    lineHeight: 60,
    borderWidth: 1,      // width of board of grid cell
    holiday: 0,
    commonday:0,
    debug: false


};
(function ($) {

  //var defaultSettings = {
  //      // Data attributes
  //      headers: [],  // String[] - Array of column headers
  //      tasks: [],    // Task[] - Array of tasks. Required fields: 
  //      // id: number, startTime: number, duration: number, column: number
        
  //      // Card template - Inner content of task card. 
  //      // You're able to use ${key} inside template, where key is any property from task.
  //      cardTemplate: '<div>${id}</div>',

  //      // OnClick event handler
  //      onClick: function (e, task) {}, //alert(e); },

  //      // Css classes
  //      containerCssClass: 'skeduler-container',
  //      headerContainerCssClass: 'skeduler-headers',
  //     // dateContainerCssClass: 'skeduler-date',
  //      schedulerContainerCssClass: 'skeduler-main',
  //      taskPlaceholderCssClass: 'skeduler-task-placeholder',
  //      cellCssClass: 'skeduler-cell',
  //      titleClass: 'titleClass',

  //      // lineHeight: 30,      // height of one half-hour line in grid
  //      lineHeight: 60,
  //      borderWidth: 1,      // width of board of grid cell

  //      debug: false
     
   
  //};
 
  var settings = {};

  /**
   * Convert double value of hours to zero-preposited string with 30 or 00 value of minutes
   */

 

  function toTimeString(value) {
      
    return (value < 10 ? '0' : '') + Math.floor(value) + (Math.ceil(value) > Math.floor(value) ? ':30' : ':00');
  }

  /**
   * Return height of task card based on duration of the task
   * duration - in hours
   */
  function getCardHeight(duration) {
    return ((settings.lineHeight + settings.borderWidth) * (duration * 2)-1);
  }

  /**
   * Return top offset of task card based on start time of the task

     * startTime - in hours
   */
  function getCardTopPosition(startTime) {
      
    
      //return ((settings.lineHeight + settings.borderWidth) * (startTime * 2)) - (9 * 60);
      return ((settings.lineHeight + settings.borderWidth) * (startTime * 2)) - (10 * (2*(settings.lineHeight + settings.borderWidth)));
  
     
  }


 



  /**
  * Render card template
  */
  function renderInnerCardContent(task) {
    var result = settings.cardTemplate;
    for (var key in task) {
      if (task.hasOwnProperty(key)) {
        // TODO: replace all
        result = result.replace('${' + key + '}', task[key]);
      }
    }

    return $(result);
  }

  /**
   * Generate task cards
   */
  function appendTasks(placeholder, tasks) {
     
    var findCoefficients = function () {
      var coefficients = [];
      for (var i = 0; i < tasks.length - 1; i++) {
         
        var k = 0;
        var j = i + 1;
        while (j < tasks.length && tasks[i].startTime < tasks[j].startTime
          && tasks[i].startTime + tasks[i].duration > tasks[j].startTime) {
          k++;
          j++;
          
        }
        
        coefficients.push(k);
      }

      coefficients.push(0);
      return coefficients;
    };

    var normalize = function (args) {
      var indexes = {};
      for (var i = 0; i < args.length; i++) {
        var start = i;
        var count = 0;
        while (args[i] != 0) {
          i++;
          count++;
        }
        var end = i;
        if (count) {
          count++;
        }

        var index = 0;
        for (var j = start; j <= end; j++) {
          args[j] = count;
          indexes[j] = index++;
        }
      }

      return {args: args, indexes: indexes};
    };

    var args =
      normalize(
        findCoefficients()
      );


    

    for (var i = 0; i < args.args.length; i++) {
       
      var width = 194 / (args.args[i] || 1);

      tasks[i].width = width;
      //tasks[i].left = (args.indexes[i] * width) || 4;
      tasks[i].left = ((args.indexes[i] * width)/2)+3 || 4;
    }
   

   
   
    tasks.forEach(function (task, index) {
       
     var innerContent = renderInnerCardContent(task);
     var top = getCardTopPosition(task.startTime)-1;
     var colour = task.colour;
     var height = getCardHeight(task.duration);
     var width = task.width || 194;
     var col = task.column;
     var taskid = task.jobid;
     var left = task.left || 4;
     var timerange = task.startingtime + "-" + task.endTime;
      //defaultSettings.holiday = task.holiDayStatus;
      //defaultSettings.commonDay = task.commonDayStatus;
    
      if (task.jobid != 0) {
          var titlecard = "[" + timerange + "] " + task.title;
      }
      var holidayCard = $('<div style="background-color="#f1cca0"></div>')
     
    
          var card = $('<div data-toggle="popover" data-placement="top" data-trigger="hover" data-content=""></div>')                 //style="background-color:"'+colour+'>

          card.attr({
              style: 'top: ' + top + 'px; background-color:' + colour + ';max-height:' + (height - 2) + 'px; height: ' + (height - 2) + 'px; ' + 'width: ' + (width / 2 - 8) + 'px; left: ' + left + 'px',
              title: titlecard,

          });




          card.on('click', function (e) { taskEdit(task.jobid); settings.onClick && settings.onClick(e, task) });
          //card.on('hover', function (e) { popoverfunction();});                                           //<-------Line Added by Arshad
          card.append(innerContent)
            .appendTo(placeholder);
      
    }, this);

  }
 

  /**"
  * Generate scheduler grid with task cards
  * options:
  * - headers: string[] - array of headers
  * - tasks: Task[] - array of tasks
  * - containerCssClass: string - css class of main container
  * - headerContainerCssClass: string - css class of header container
  * - schedulerContainerCssClass: string - css class of scheduler
  * - lineHeight - height of one half-hour cell in grid
  * - borderWidth - width of border of cell in grid
  */
  $.fn.skeduler = function (options) {
    settings = $.extend(defaultSettings, options);

    if (settings.debug) {
     // console.time('skeduler');
    }

    var skedulerEl = $(this);

    skedulerEl.empty();
    skedulerEl.addClass(settings.containerCssClass);
   // var dt = settings.dateHeader;
    var div = $('<div></div>');
  
       
    
   
    //var buttonheader = $('<div></div>');
    //var headerContainer = buttonheader.clone().addClass(settings.headerContainerCssClass);
    var headerContainer = div.clone().addClass(settings.headerContainerCssClass);
    settings.headers.forEach(function (element) {
  
       
        //buttonheader.clone().text(element).appendTo(headerContainer)
        
        div.clone().text(element).appendTo(headerContainer).attr({});
       
    }, this);
    skedulerEl.append(headerContainer);





   

    // Add schedule
    var scheduleEl = div.clone().addClass(settings.schedulerContainerCssClass);
    var scheduleTimelineEl = div.clone().addClass(settings.schedulerContainerCssClass + '-timeline');
    var scheduleBodyEl = div.clone().addClass(settings.schedulerContainerCssClass + '-body');
    //var scheduleBodyEn = div.clone().addClass(settings.cellCssClass + 'skeduler-cell');
    var ilimit = 12;
    
        var gridColumnElement = div.clone();
        var bodyColumnElement = div.clone();
        var count = 0;
        var bgcolor;
        //(settings.tasks).forEach(function (task, index) {

        //    if (task.commonDayStatus == 1 || task.holiDayStatus == 1) {
        //        bgcolor = "#f1cca0";
                
        //    }

      //});
       
        if (settings.tasks[0].commonDayStatus == 1 || settings.tasks[0].holiDayStatus == 1) {
           
            bgcolor = "#f1cca0";
        }
        for (var i = 10; i <= ilimit; i++) {                //Generating Time on TimeLine
            // Populate timeline
           
            if (ilimit == 10 && i == 10) {
                break;
            }
           
           
                      //if ((tasklist.commonDayStatus[0] == 1) || tasklist.holiDayStatus[0] == 1) {
            //    
            //}
            //else { bgcolor = "white";}
           // alert(settings.tasks[2]);
            



           div.clone()
                  .text(toTimeString(i))
                    .appendTo(scheduleTimelineEl).attr('style', 'height:58px;');
                    
            div.clone().appendTo(scheduleTimelineEl).attr('style', 'height:56px');
           
            gridColumnElement.append(div.clone().addClass(settings.cellCssClass).attr('onClick', 'newAssign(this,' + i + ',"' + bgcolor + '")').attr('id', i).attr('style', 'height:60px;background-color: ' + bgcolor + ''));
            
            gridColumnElement.append(div.clone().addClass(settings.cellCssClass).attr('onClick', 'newAssign(this,' + (i + .5) + ',"' + bgcolor + '")').attr('id', (i + .5)).attr('style', 'height:60px;background-color: ' + bgcolor + ''));
           
            if (i == 12) { i = 0; ilimit = 10; }
        
         
        }
        
   


       //Populate grid
    for (var j = 0; j < settings.headers.length; j++) {
        var el = gridColumnElement.clone().attr('id', j);
      
        var placeholder = div.clone().addClass(settings.taskPlaceholderCssClass).attr('id', j);
      appendTasks(placeholder, settings.tasks.filter(function (t) { return t.column == j }));
     
      el.prepend(placeholder);
      el.appendTo(scheduleBodyEl);
    }

    scheduleEl.append(scheduleTimelineEl);
    scheduleEl.append(scheduleBodyEl);

    skedulerEl.append(scheduleEl);

    if (settings.debug) {
      //console.timeEnd('skeduler');
    }

    return skedulerEl;
  };
}(jQuery));
