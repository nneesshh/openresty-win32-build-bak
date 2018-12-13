'use strict';

window.chartColors = {
	red: 'rgba(255, 99, 132, 0.9)',
	orange: 'rgba(255, 159, 64, 0.9)',
	yellow: 'rgba(255, 205, 86, 0.9)',
	green: 'rgba(75, 192, 192, 0.9)',
	blue: 'rgba(54, 162, 235, 0.9)',
	purple: 'rgba(153, 102, 255, 0.9)',
	grey: 'rgba(201, 203, 207, 0.9)',
	darkgreen: 'rgba(0, 100, 0, 0.9)',
	darkblue: 'rgba(0, 0, 139, 0.9)',
	indigo: 'rgba(75, 0, 130, 0.9)',
};

function chart_utils_addDataset(datasetList, labelName, dataList) {
	var colorNames = Object.keys(window.chartColors);
	var colorName = colorNames[datasetList.length % colorNames.length];
	var newColor = window.chartColors[colorName];
	var newDataset = {
		label: labelName,
		backgroundColor: newColor,
		borderColor: newColor,
		data: dataList,
		fill: false
	};

	datasetList.push(newDataset);
};
