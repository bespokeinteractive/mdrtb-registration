<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Active Patients"])
	
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
			programId:	${program}
		}
		
		jq.getJSON(emr.fragmentActionLink("mdrtbregistration", "search", "searchActivePatients"), requestData)
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
			var names = '<a href="../mdrtbdashboard/main.page?patient='+result.patientDetails.patientProgram.patient.patientId+'&programId='+result.patientDetails.patientProgram.id+'">' + result.wrapperNames + '</a>';
			var remarks = 'N/A';
			var icons = '<a href="editPatient.page?patient=' + result.patientDetails.patientProgram.patient.patientId + '"><i class="icon-edit small"></i></a> <a href="../mdrtbdashboard/main.page?patient=' + result.patientDetails.patientProgram.patient.patientId + '"><i class="icon-group small"></i></a> <a href="../mdrtbdashboard/main.page?patient=' + result.patientDetails.patientProgram.patient.patientId + '&tabs=chart"><i class="icon-bar-chart small"></i></a> <a class="remove-patient" data-idnt='+result.patientDetails.patientProgram.id+'><i class="icon-remove small red"></i></a>';
			var gender = 'Male';
			
			if (result.patientDetails.patientProgram.patient.gender == 'F'){
				gender = 'Female';
			}
			
			dataRows.push([0, result.wrapperIdentifier, names, result.patientDetails.patientProgram.patient.age, gender, result.patientDetails.patientProgram.program.name, icons]);
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
				"sInfo": "_TOTAL_ ${program==2?'MDR-':''}TB Patient(s) Found",
				"sInfoEmpty": " ",
				"sZeroRecords": "No ${program==2?'MDR-':''}TB Patients Found",
				"sInfoFiltered": "Showing _TOTAL_ of _MAX_ ${program==2?'MDR-':''}TB Patients",
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
		
		jq("#session-location ul.select").on('click', 'li', function (event) {
			if (jq('#locations').val() != 0){
				jq('#locations').val(locationId);
				
				getMdrtbpatients();
			}			
		});
		
		jq('#searchList').on('click', '.remove-patient', function(event){
			var programId = jq(this).data('idnt');
			
			jq.getJSON('${ui.actionLink("mdrtbdashboard", "dashboard" ,"getPatientProgramDetails")}', {
				programId : programId
			}).success(function (data) {
				jq('#patientIdnt').val(data.identifier);
				jq('#patientName').val(data.names);
				jq('#identifier').val(programId);
				jq('#patientRemarks').val('');
				
				voidDialog.show();
			});
		});
		
		jq('#searchPhrase').on('keyup', function(){
			searchTable.api().search(this.value).draw();
		});
		
		var voidDialog = emr.setupConfirmationDialog({
			dialogOpts: {
				overlayClose: false,
				close: true
			},
			selector: '#void-dialog',
			actions: {
				confirm: function() {
					if (jq('#patientRemarks').val().trim() == ''){
						jq().toastmessage('showErrorToast', 'Ensure that the delete reason has been specified');
						return false;
					}
					
					jq.ajax({
						type: "POST",
						url: '${ui.actionLink("mdrtbdashboard", "dashboard", "voidPatient")}',
						data: ({
							programId:	jq('#identifier').val(),
							reasons:	jq('#patientRemarks').val()
						}),
						dataType: "json",
						success: function(data) {
							if (data.status == "success"){
								jq().toastmessage('showSuccessToast', data.message);
								window.location.href = "active.page?program=${program}";
							}
							else {
								jq().toastmessage('showErrorToast', 'x:'+ data.message);
							}							
						},
						error: function(data){
							jq().toastmessage('showErrorToast', "Post Failed. " + data.statusText);
						}
					});
					
				},
				cancel: function() {
					voidDialog.close();
				}
			}
		});
		
		getMdrtbpatients();
	});
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
	i.icon-search{
		color: #ccc;
		float: left;
		margin-left: 7px;
		margin-top: -35px;
	}
	.new-patient-header .demographics {
		display: inline-block;
		width: 100%;
	}
	a.other-type{
		float: right;
		font-size: 0.75em;
		margin: 20px 3px 0;
	}
	i.red {
		color: f00;
	}
	#modal-overlay {
		background: #000 none repeat scroll 0 0;
		opacity: 0.3!important;
	}
	#visit-dialog.dialog {
		width: 500px;
	}	
	.dialog .dialog-content li {
		margin-bottom: 0;
	}
	.dialog-content ul li label{
		display: inline-block;
		width: 120px;
	}
	.dialog-content ul li input[type=text],
	.dialog-content ul li select,
	.dialog-content ul li textarea {
		border: 1px solid #ddd;
		display: inline-block;
		height: 40px;
		margin: 1px 0;
		min-width: 20%;
		padding: 5px 0 5px 10px;
		width: 67%;
	}
	form input:focus, 
	form select:focus, 
	form textarea:focus, 
	form ul.select:focus, 
	.form input:focus, 
	.form select:focus, 
	.form textarea:focus, 
	.form ul.select:focus {
		background: lightyellow none repeat scroll 0 0;
		outline: 0px none #007fff;
	}
	.add-on {
		left: auto;
		margin-left: -39px;
		position: relative;
	}	
	.dialog select option {
		font-size: 1em;
	}
	label span.mandatory {
		color: #f00;
		float: right;
		padding-right: 5px;
	}
	.dialog ul {
		margin-bottom: 20px;
	}
	.button.confirm{
		margin-right: 6px;
	}
	.outcome {
		display: none;
	}
	.dropdown ul {
		position: absolute;
		right: 4px;
	}
	.dropdown ul li {
		cursor: pointer;
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
                <a href="search.page">Search</a>
            </li>
            <li>
				<i class="icon-chevron-right link"></i>
                <a href="#">${program==2?'MDR-':''}TB Patients</a>
            </li>
        </ul>
    </div>
	
    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name" style="border-bottom: 1px solid #ddd;">
                <span>ACTIVE ${program==2?'MDR-':''}TB PATIENTS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
            </h1>
			
			<a href="active.page?program=${program==1?2:1}" class="other-type">View ${program==1?'MDR-':''}TB Patients</a>
            <br/>
        </div>
		
        <div class="onepcssgrid-1000">
            <br/><br/>
			
			<form onsubmit="return false" id="patient-search-form" method="get" style="margin: 0px;">
				<input type="text" autocomplete="off" placeholder="Filter Patient List" id="searchPhrase" style="float:left; width:100%; padding:6px 10px 7px 35px;">
				<i class="icon-search small"></i>
				<img id="ajaxLoader" style="display:none; float:left; margin: 3px -4%;" src="${ui.resourceLink("registration", "images/ajax-loader.gif")}"/>
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

<div id="void-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>
        <h3>REMOVE PATIENT</h3>
    </div>

    <div class="dialog-content">
        <ul>
			<li>
				<label for="dstLabNumber">
					IDENTIFIER :
				</label>
				<input type="text" name="patient.identifier" id="patientIdnt" readonly="" />
				<input type="hidden" name="patient.idnt" id="identifier" readonly="" />
			</li>
			
			<li>
				<label for="dstLabNumber">
					PATIENT :
				</label>
				<input type="text" name="patient.name" id="patientName" readonly="" />
			</li>
			
			<li>
				<label for="MdrtbRemarks" style="margin-top: 10px;">
					REASONS :
				</label>
				<textarea id="patientRemarks" name="program.remarks" placeholder="Remarks" style="height:100px; resize:none;"></textarea>
			</li>
        </ul>

        <label class="button confirm right">Confirm</label>
        <label class="button cancel">Cancel</label>
    </div>
</div>