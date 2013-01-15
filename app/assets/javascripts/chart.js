$(function() {
  try {
    // check for the existence of the chart div
    if ($('#chart').length) {
      var chart;

      // define the options
      var options = {
        chart: {
          renderTo: 'chart',
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
              '<br/><strong>Match date:</strong> ' + this.points[0].point.options.date;
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

      var url = '/players/' + $('#chart').data('player-id') + '/';
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
  }
  catch (e) {
    console.log(e);
  }
});
