$(function() {
  try {
    var chart;
    var options;

    // check for the existence of the chart div
    if ($('#batting_chart').length) {
      // define the options
      options = {
        chart: {
          renderTo: 'batting_chart',
          type: 'spline'
        },

        title: {
          text: 'Innings'
        },

        xAxis: {
          type: 'linear',
          title: {
            text: 'Inning number'
          }
        },

        yAxis: {
          title: {
            text: 'Runs'
          },
          min: 0,
          startOnTick: false
        },

        tooltip: {
          shared: true,
          formatter: function() {
            var not_out = 'No';
            if (this.points[0].point.options.not_out) {
              not_out = 'Yes';
            }

            return '<strong>Runs:</strong> ' + this.y +
              '<br/><strong>Average:</strong> ' + this.points[1].y +
              '<br/><strong>Moving Average:</strong> ' + this.points[2].y +
              '<br/><strong>Not Out:</strong> ' + not_out +
              '<br/><strong>Match date:</strong> ' + this.points[0].point.date;
          }
        },

        series: [{
          name: 'Runs',
          data: []
        }, {
          name: 'Average',
          data: []
        }, {
          name: 'Moving Average (10 innings)',
          data: []
        }]
      };

      var url = '/players/' + $('#batting_chart').data('player-id') + '/';
      jQuery.get(url + 'batting_innings.json', null, function(innings, state, xhr) {
        var runs = [];
        var average = [];
        var moving_average = [];
        var total = 0, outs = 0;

        jQuery.each(innings, function(i, inning) {
          inning.y = inning.runs;
          runs.push(inning);
          total += inning.runs;
          if (!inning.not_out) {
            outs++;
          }
          if (outs > 0) {
            average.push(Number((total / outs).toFixed(2)));
          }
          else {
            average.push(null);
          }

          if (inning.moving_average == null) {
            moving_average.push(inning.moving_average);
          }
          else {
            moving_average.push(Number(inning.moving_average));
          }
        });

        options.series[0].data = runs;
        options.series[1].data = average;
        options.series[2].data = moving_average;
        chart = new Highcharts.Chart(options);
      });
    }

    if ($('#bowling_chart').length) {
      // define the options
      options = {
        chart: {
          renderTo: 'bowling_chart',
          type: 'spline'
        },

        title: {
          text: 'Innings'
        },

        xAxis: {
          type: 'linear',
          title: {
            text: 'Inning number'
          }
        },

        yAxis: {
          title: {
            text: 'Runs'
          },
          min: 0,
          startOnTick: false
        },

        tooltip: {
          shared: true,
          formatter: function() {
            return '<strong>Wickets:</strong> ' + this.y +
              '<br/><strong>Runs:</strong> ' + this.points[1].y +
              '<br/><strong>Average:</strong> ' + this.points[2].y +
              '<br/><strong>Match date:</strong> ' + this.points[0].point.date;
          }
        },

        series: [{
          name: 'Wickets Taken',
          data: []
        }, {
          name: 'Runs Conceded',
          data: []
        }, {
          name: 'Average',
          data: []
        }]
      };

      var url = '/players/' + $('#bowling_chart').data('player-id') + '/';
      jQuery.get(url + 'bowling_innings.json', null, function(innings, state, xhr) {
        var wickets = [];
        var runs = [];
        var average = [];
        var total = 0, total_wickets = 0;

        jQuery.each(innings, function(i, inning) {
          inning.y = inning.wickets;
          wickets.push(inning);
          runs.push(inning.runs);
          total += inning.runs;
          total_wickets += inning.wickets;

          if (total_wickets > 0) {
            average.push(Number((total / total_wickets).toFixed(2)));
          }
          else {
            average.push(null);
          }

        });

        options.series[0].data = wickets;
        options.series[1].data = runs;
        options.series[2].data = average;
        chart = new Highcharts.Chart(options);
      });
    }
  }
  catch (e) {
    console.log(e);
  }
});
