<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Search Patients"])
	
	ui.includeCss("mdrtbregistration", "onepcssgrid.css")
	ui.includeCss("uicommons", "datatables/dataTables_jui.css")
	
    ui.includeJavascript("mdrtbregistration", "jq.dataTables.min.js")
%>

<script>
	var searchTable;
	var searchTableObject;
	var searchResultsData = [];
	var searchHighlightedKeyboardRowIndex;
	
	var getMdrtbpatients = function(){
		searchTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		var requestData = {
			phrase: 		jq('#searchPhrase').val(),
			gender: 		jq('#gender').val(),
			age: 			jq('#age').val(),
			ageRange: 		jq('#ageRange').val(),
			lastDayOfVisit:	jq('#lastDayOfVisit-field').val(),
			lastVisit: 		jq('#lastVisit').val(),
			locations:		jq('#locations').val(),
            programId:      0
		}
		
		jq.getJSON(emr.fragmentActionLink("mdrtbregistration", "search", "searchPatient"), requestData)
			.success(function (data) {
				updateSearchResults(data);
			}).error(function (xhr, status, err) {
				updateSearchResults([]);
			}
		);
	};
	
	var updateSearchResults = function(results){
		searchResultsData = results || [];
		var dataRows = [];
		_.each(searchResultsData, function(result){
			var names = '<a class="redirect" data-idnt="' + result.patientProgram.patient.patientId + '" data-location="' + result.wrapperLocationId + '" >' + result.wrapperNames + '</a>';
			var remarks = 'N/A';
			var icons = '<a href="editPatient.page?patient=' + result.patientProgram.patient.patientId + '"><i class="icon-edit small"></i></a> <a href="../mdrtbdashboard/main.page?patient=' + result.patientProgram.patient.patientId + '&mode=view"><i class="icon-group small"></i></a> <a href="../mdrtbdashboard/main.page?patient=' + result.patientProgram.patient.patientId + '&tabs=chart"><i class="icon-bar-chart small"></i></a>';
			var gender = 'Male';
			
			if (result.patientProgram.patient.gender == 'F'){
				gender = 'Female';
			}
			
			dataRows.push([0, result.wrapperIdentifier, names, result.patientProgram.patient.age, gender, result.wrapperStatus, icons]);
		});

		searchTable.api().clear();
		
		if(dataRows.length > 0) {
			searchTable.fnAddData(dataRows);
		}

		refreshInTable(searchResultsData, searchTable);
	};
	
	var refreshInTable = function (resultData, dTable) {
        var rowCount = resultData.length;
        if (rowCount == 0) {
            dTable.find('td.dataTables_empty').html("No Records Found");
        }
        dTable.fnPageChange(0);
    };

    var isTableEmpty = function (resultData, dTable) {
        if (resultData.length > 0) {
            return false
        }
        return !dTable || dTable.fnGetNodes().length == 0;
    };	
	
	jq(function () {
		searchTableObject = jq("#searchList");
		
		searchTable = searchTableObject.dataTable({
			bFilter: true,
			bJQueryUI: true,
			bLengthChange: false,
			iDisplayLength: 25,
			sPaginationType: "full_numbers",
			bSort: false,
			sDom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			oLanguage: {
				"sInfo": "_TOTAL_ Patient(s) Found",
				"sInfoEmpty": " ",
				"sZeroRecords": "No Patients Found in the selected Location",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_ Patients)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(searchResultsData, searchTable)){
					//this should ensure that nothing happens when the use clicks the
					//row that contain the text that says 'No data available in table'
					return;
				}

				if(searchHighlightedKeyboardRowIndex != undefined && !isHighlightedRowOnVisiblePage()){
					unHighlightRow(searchTable.fnGetNodes(searchHighlightedKeyboardRowIndex));
				}
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		searchTable.on( 'order.dt search.dt', function () {
			searchTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
		//End of DataTables
	
	
	
		jq('#as_close').click(function(){
			jq('#dashboard').hide(100);
			jq('#patient-search-form').clearForm();
		});
		
		jq('#advanced').click(function(){
			jq('#dashboard').toggle(300);
			jq('#patient-search-form').clearForm();
		});
		
		jq('#searchPhrase').on('keyup', function(){
			getMdrtbpatients();
		});
		
		jq('input, select').keydown(function (e) {
			var key = e.keyCode || e.which;
			if (key == 9 || key == 13) {
				getMdrtbpatients(); 
			}
		});
		
		jq('input, select').on('blur', function(){
			if (jq(this).attr('id') !== 'searchPhrase'){
				getMdrtbpatients();
			}
		});
		
		jq('#lastDayOfVisit-display').change(function(){
			getMdrtbpatients();
		});
		
		
		if ('${phrase}' !== ''){
			getMdrtbpatients();
		}
		
		jq("#session-location ul.select").on('click', 'li', function (event) {
			if (jq('#locations').val() != 0){
				jq('#locations').val(locationId);

				//Refresh the Table if it's not empty
				if (searchTable.fnSettings().aoData.length > 0 || jq('#searchPhrase').val().length > 0){
					getMdrtbpatients();
				}
			}			
		});
		
		jq("#searchList").on('click','.redirect', function(){
			var idnt = jq(this).data('idnt');
			var loc1 = jq(this).data('location');
			var loc2 = locationId?locationId:${sessionContext.sessionLocationId};
			
			if (loc1 == loc2){
				window.location.href = "../mdrtbdashboard/main.page?patient=" + idnt;
			}
			else {
				window.location.href = "../mdrtbdashboard/transferIn.page?patient=" + idnt;
			}
		});
		
		jq('#locations').val(${sessionContext.sessionLocationId});
	});
	
	jq.fn.clearForm = function() {
		return this.each(function() {
			var type = this.type, tag = this.tagName.toLowerCase();
			if (tag == 'form')
			  return jQuery(':input',this).clearForm();
			if ((type == 'text' || type == 'hidden') && jQuery(this).attr('id') != 'searchPhrase')
			  this.value = '';
			else if (type == 'checkbox' || type == 'radio')
			  this.checked = false;
			else if (tag == 'select' && jq(this).attr('id') != 'locations')
			  this.selectedIndex = -1;
		});
	};
</script>

<style>
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}
	body {
		margin-top: 20px;
	}
	.col1, .col2, .col3, .col4, .col5, .col6, .col7, .col8, .col9, .col10, .col11, .col12 {
		color: #555;
		text-align: left;
	}

	form input{
		margin: 0px;
		display: inline-block;
		min-width: 50px;
		padding: 2px 10px;
	}
	.info-header span{
		cursor: pointer;
		display: inline-block;
		float: right;
		margin-top: -2px;
		padding-right: 5px;
	}
	.dashboard .info-section {
		margin: 2px 5px 5px;
	}
	.toast-item{
		background-color: #222;
	}
	form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus{
		outline: 1px none #007fff;
		box-shadow: 0 0 1px 0px #888!important;
	}
	.name {
		color: #f26522;
	}
	@media all and (max-width: 768px) {
		.onerow {
			margin: 0 0 100px;
		}
	}
	form .advanced {
		background: #363463 none repeat scroll 0 0;
		border-color: #dddddd;
		border-style: solid;
		border-width: 1px;
		color: #fff;
		cursor: pointer;
		float: right;
		padding: 5px 0;
		text-align: center;
		width: 27%;
	}
	form .advanced i{
		font-size: 24px;
	}
	.col4 label {
		width: 110px;
		display: inline-block;
	}

	.col4 input[type=text] {
		display: inline-block;
		padding: 2px 10px;
	}

	.col4 select {
		padding: 2px 10px;
	}

	form select {
		min-width: 50px;
		display: inline-block;
	}
	.addon{
		display: inline-block;
		float: right;
		margin: 5px 0 0 145px;
		position: absolute;
	}
	#lastDayOfVisit label{
		display:none;
	}
	#lastDayOfVisit input{
		width:172px !important;
		height: 34px;
	}
	.add-on {
		float: right;
		left: auto;
		margin-left: -29px;
		margin-top: 5px;
		position: absolute;
		color: #f26522;
	}
	.ui-widget-content a {
		color: #007fff;
	}
	td a{
		cursor: pointer;
		text-decoration: none;
	}
	td:nth-child(4){
		text-align: center;
	}
	td:nth-child(5){
		text-transform: capitalize;
	}
	.recent-seen{
		background: #fff799 none repeat scroll 0 0!important;
		color: #000 !important;
	}
	.recent-lozenge {
		border: 1px solid #f00;
		border-radius: 4px;
		color: #f00;
		display: inline-block;
		font-size: 0.7em;
		padding: 1px 2px;
		vertical-align: text-bottom;
	}
	table th, table td {
		white-space: nowrap;
	}
	#locations option:last-child{
		border-top: 1px dotted #333;
		margin-top: 3px;
	}
</style>

<div class="clear"></div>
<div class="container">
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication','home')}">
                    <i class="icon-home small"></i></a>
            </li>
            <li>
                <i class="icon-chevron-right link"></i>
                <a href="#">Find Patients</a>
            </li>
            <li>
            </li>
        </ul>
    </div>
	
    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name" style="border-bottom: 1px solid #ddd;">
                <span>FIND PATIENT RECORDS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
            </h1>
            <br/>
        </div>
		
        <div class="onepcssgrid-1000">
            <br/><br/>
			
			<form onsubmit="return false" id="patient-search-form" method="get" style="margin: 0px;">
				<input type="text" autocomplete="off" placeholder="Search by TBMU No or Name" id="searchPhrase"
					   style="float:left; width:70%; padding:6px 10px 7px;" value="${phrase?phrase:''}">
				<img id="ajaxLoader" style="display:none; float:left; margin: 3px -4%;" src="${ui.resourceLink("registration", "images/ajax-loader.gif")}"/>

				<div id="advanced" class="advanced"><i class="icon-filter"></i>ADVANCED SEARCH</div>

				<div id="dashboard" class="dashboard" style="display:none;">
					<div class="info-section">
						<div class="info-header">
							<i class="icon-diagnosis"></i>

							<h3>ADVANCED SEARCH</h3>
							<span id="as_close">
								<div class="identifiers">
									<span style="background:#00463f; padding-bottom: 5px;">x</span>
								</div>
							</span>
						</div>

						<div class="info-body" style="min-height: 75px;">
							<ul>
								<li>
									<div class="onerow" style="padding-top: 0px;">
										<div class="col4">
											<label for="age">Age</label>
											<input id="age" name="age" style="width: 172px; height: 34px;" placeholder="Patient Age">
										</div>										

										<div class="col4">
											<label for="gender">Previous Visit</label>
											<select style="width: 172px" id="lastVisit">
												<option value="">Anytime</option>
												<option value="31">Last month</option>
												<option value="183">Last 6 months</option>
												<option value="366">Last year</option>
											</select>
										</div>

										<div class="col4 last">
											<label for="gender">Gender</label>
											<select style="width: 172px" id="gender" name="gender">
												<option value="">Any</option>
												<option value="M">Male</option>
												<option value="F">Female</option>
											</select>
										</div>
										
									</div>

									<div class="onerow" style="padding-top: 0px;">
										<div class="col4">
											<label for="ageRange">Range &plusmn;</label>
											<select id="ageRange" name="ageRange" style="width: 172px">
												<option value="0">Exact</option>
												<option value="1">1</option>
												<option value="2">2</option>
												<option value="3">3</option>
												<option value="4">4</option>
												<option value="5">5</option>
											</select>
										</div>

										<div class="col4">
											<label for="lastDayOfVisit">Last Visit</label>
											${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'lastDayOfVisit', id: 'lastDayOfVisit', label: '', useTime: false, defaultToday: false, class: ['newdtp'], endDate: new Date()])}
										</div>

										<div class="col4 last">
											<label for="locations">Location</label>
											<select style="width: 172px" id="locations" name="locations">
												<option value="0">My Locations</option>
												<% locations.eachWithIndex { location, index -> %>
													<option value="${location.id}">${location.name}</option>
												<% } %>
												<option value="-1">All Locations</option>
											</select>
										</div>
									</div>
								</li>
							</ul>
							<div class="clear"></div>
						</div>
					</div>
				</div>
			</form>
			
			<div id="receipts" style="display: block; margin-top:3px;">
				<table id="searchList">
					<thead>
						<th>#</th>
						<th>IDENTIFIER</th>
						<th>NAMES</th>
						<th>AGE</th>
						<th>GENDER</th>
						<th>STATUS</th>
						<th>ACTIONS</th>
					</thead>
					
					<tbody>			
					</tbody>
				</table>
			</div>
			
			
			
			
			
			
			
			
			
			
			
        </div>
    </div>
</div>