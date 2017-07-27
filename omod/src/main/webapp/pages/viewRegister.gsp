<%
    ui.decorateWith("appui", "standardEmrPage", [title: "TB Patients Register"])
	
	ui.includeCss("mdrtbregistration", "onepcssgrid.css")
	ui.includeCss("uicommons", "datatables/dataTables_jui.css")
	
    ui.includeJavascript("mdrtbregistration", "jq.dataTables.min.js")
%>

<script>
	var registerTable;
	var registerTableObject;
	var registerResultsData = [];
	var searchHighlightedKeyboardRowIndex;
	
	var getPatientRegister = function(){
		registerTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		var requestData = {
			phrase: 		'',
			gender: 		jq('#gender').val(),
			age: 			jq('#age').val(),
			ageRange: 		jq('#ageRange').val(),
			lastDayOfVisit:	'',
			lastVisit: 		0,
			site:			jq('#site').val(),
			status:			jq('#status').val(),
			outcome:		jq('#outcome').val(),
			enrolled:		jq('#enrolled').val(),
			finished:		jq('#finished').val(),
			diagnosis:		jq('#diagnosis').val(),
			artstatus:		jq('#artstatus').val(),
			cptstatus:		jq('#cptstatus').val(),
			programId:		jq('#program').val(),
			locations:		jq('#locations').val()
		}
		
		jq.getJSON(emr.fragmentActionLink("mdrtbregistration", "search", "searchPatient"), requestData)
			.success(function (data) {
				updateRegisterResults(data);
			}).error(function (xhr, status, err) {
				updateRegisterResults([]);
			}
		);
	};
	
	var updateRegisterResults = function(results){
		registerResultsData = results || [];
		var dataRows = [];
		_.each(registerResultsData, function(result){
			var names = '<a class="redirect" data-idnt="' + result.patientProgram.patient.patientId + '" data-location="' + result.wrapperLocationId + '" >' + result.wrapperNames + '</a>';		
			var sites = result.patientDetails.diseaseSite.name == 'PULMONARY TUBERCULOSIS'?'PB':'EP'
			dataRows.push([0, result.wrapperRegisterDate, result.wrapperIdentifier, names, result.patientProgram.patient.gender, result.patientProgram.patient.age, result.wrapperAddress, result.patientDetails.facility.name, result.patientDetails.daamin, 'YES', result.wrapperTreatmentDate, result.patientDetails.patientCategory.concept.name, sites, result.patientDetails.patientType.concept.name, result.wrapperCompletedDate, result.wrapperOutcome, result.wrapperArt, result.wrapperCpt]);
		});

		registerTable.api().clear();
		
		if(dataRows.length > 0) {
			registerTable.fnAddData(dataRows);
		}

		refreshInTable(registerResultsData, registerTable);
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
		registerTableObject = jq("#registerList");
		
		registerTable = registerTableObject.dataTable({
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
				"sZeroRecords": "No Patients Found",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_ Patients)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(registerResultsData, registerTable)){
					//this should ensure that nothing happens when the use clicks the
					//row that contain the text that says 'No data available in table'
					return;
				}

				if(searchHighlightedKeyboardRowIndex != undefined && !isHighlightedRowOnVisiblePage()){
					unHighlightRow(registerTable.fnGetNodes(searchHighlightedKeyboardRowIndex));
				}
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		registerTable.on( 'order.dt search.dt', function () {
			registerTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
		//End of DataTables
	
	
	
		jq("#session-location ul.select").on('click', 'li', function (event) {
			if (jq('#locations').val() != 0){
				jq('#locations').val(locationId);

				//Refresh the Table if it's not empty
				if (registerTable.fnSettings().aoData.length > 0 || jq('#searchPhrase').val().length > 0){
					getPatientRegister();
				}
			}			
		});
		
		jq("#registerList").on('click','.redirect', function(){
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
		
		jq('#advanced').click(function(){
			jq('.content-filter').toggle();
			var adv = jq('#advanced i')
			
			if(adv.hasClass("icon-double-angle-down")){
				adv.removeClass("icon-double-angle-down");
				adv.addClass("icon-double-angle-up");
			}
			else {
				adv.removeClass("icon-double-angle-up");
				adv.addClass("icon-double-angle-down");
			}
		});
		
		jq('input, select').keydown(function (e) {
			var key = e.keyCode || e.which;
			if (key == 13) {
				getPatientRegister(); 
			}
		});
		
		jq('input, select').on('change', function(){
			if (jq(this).attr('id')=='enrolled' || jq(this).attr('id')=='finished'){
				return false;
			}
			getPatientRegister();
		});
		
		jq('#enrolled, #finished').on('blur', function(){
			var data = jq(this).val().replace('/', '-').split('-');
			if (data.length == 2){
				if (!jq.isNumeric(data[0]) || !jq.isNumeric(data[1])){
					jq(this).val('');
				}				
				else if(data[0] > 4){
					data[0]=4;
				}
				else if(data[0] < 1){
					data[0]=1;
				}
				
				if (jq(this).val().length == 4){
					jq(this).val('0'+data[0]+'/20'+data[1]);
				}
				else if (jq(this).val().length == 5){
					jq(this).val(data[0]+'/20'+data[1]);
				}
				else if (jq(this).val().length == 6 || jq(this).val().length == 7){
					
				}
				else {
					jq(this).val('');
				}
			}
			else {
				jq(this).val('');
			}
			
			getPatientRegister();
		});
		
		jq('#locations').val(${sessionContext.sessionLocationId});
		
		getPatientRegister();
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
	td:nth-child(4),
	td:nth-child(7),
	td:nth-child(9){
		text-transform: uppercase;
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
	#body-wrapper {
		max-width: 1400px;
		width: 1400px;
	}
	table {
		font-size: 12px;
	}
	.advanced {
		background: #363463 none repeat scroll 0 0;
		border-color: #dddddd;
		border-style: solid;
		border-width: 1px;
		color: #fff;
		cursor: pointer;
		float: right;
		padding: 5px 0;
		text-align: center;
		width: 190px;
	}
	.content-filter{
		border: 1px solid #ddd;
		display: none;
		margin-top: 2px;
		min-height: 170px;
		padding-top: 5px;
	}	
	.content-filter div{
		box-sizing: border-box;
		-moz-box-sizing: border-box;
		-webkit-box-sizing: border-box;
		
		border-right: 1px solid #ddd;
		display: inline-block;
		float: left;
		min-height: 165px;
		padding: 10px;
		width: 25%;
	}
	.content-filter div:last-child{		
		border-right: 0px none #ddd;
	}
	
	.content-filter label{
		display: inline-block;
		width: 110px;
		margin-bottom: 0;
		margin-top: 8px;
	}
	
	.content-filter input,
	.content-filter select{
		border: 1px solid #ddd;
		color: #363463;
		height: 34px;
		width: 205px;
		padding: 0 10px;
	}
	.content-filter select option{
		padding: 2px 10px;
	}
	.first-underline option:first-child{
		border-bottom: 1px dotted #333;
		margin-bottom: 3px;
		padding-bottom: 3px;
	}
	.last-underline option:last-child {
		border-top: 1px dotted #333;
		margin-top: 3px;
	}
	.dataTables_wrapper {
		min-height: 0;
	}
	div.export {
		display: inline-block;
		float: right;
		font-size: 0.9em;
		margin: 10px 20px 0 0;
	}
	div.export a{
		text-decoration: underline;
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
                <a href="">Tb Register</a>
            </li>
        </ul>
    </div>
	
    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name" style="border-bottom: 1px solid #ddd;">
                <span>&nbsp;BASIC MANAGEMENT UNIT TB REGISTER &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
            </h1>
			
			<div id="advanced" class="advanced">
				<i class="icon-double-angle-down small"></i>
				FILTER PATIENTS
			</div>
			
			<div class="export"><a href="">Export Register</a></div>
        </div>
		<div class="clear both"></div>
		
		<div class='content-filter'>
			<div class="rows1">
				<field>
					<label for="age">Patient Age</label>
					<input id="age" name="age" placeholder="Patient Age">
				</field>
				
				<field>
					<label for="ageRange">Age Range &plusmn;</label>
					<select id="ageRange" name="ageRange">
						<option value="0">Exact</option>
						<option value="1">1</option>
						<option value="2">2</option>
						<option value="3">3</option>
						<option value="4">4</option>
						<option value="5">5</option>
					</select>
				</field>
				
				<field>
					<label for="gender">Gender</label>
					<select id="gender" name="gender" class="first-underline">
						<option value="">Any</option>
						<option value="M">Male</option>
						<option value="F">Female</option>
					</select>
				</field>
			</div>
			
			<div class="rows2">
				<field>
					<label for="program">Program</label>
					<select id="program" name="program" class="first-underline">
						<option value="-1">All Programs</option>
						<option value="1">TB Patients</option>
						<option value="2">MDRTB Patients</option>
					</select>
				</field>
				
				<field>
					<label for="locations">Location</label>
					<select id="locations" name="locations" class="first-underline last-underline">
						<option value="0">My Locations</option>
						<% locations.eachWithIndex { location, index -> %>
							<option value="${location.id}">${location.name}</option>
						<% } %>
						<option value="-1">All Locations</option>
					</select>
				</field>
				
				<field>
					<label for="enrolled">QTR Enrolled</label>
					<input id="enrolled" name="enrolled" placeholder="MM/YYYY">
				</field>
				
				<field>
					<label for="finished">QTR Finished</label>
					<input id="finished" name="finished" placeholder="MM/YYYY">
				</field>
			</div>
			
			<div class="rows3">
				<field>
					<label for="status">Status</label>
					<select id="status" name="status" class="first-underline">
						<option value="0">All Programs</option>
						<option value="1">ACTIVE PROGRAM</option>
						<option value="2">NOT-IN PROGRAM</option>
					</select>
				</field>
				
				<field>
					<label for="site">Site</label>
					<select id="site" name="site" class="first-underline">
						<option value="0">All Sites</option>
						<option value="63">PULMONARY TB</option>
						<option value="163">EXTRA-PULMONARY TB</option>
					</select>
				</field>
				
				<field>
					<label for="diagnosis">Diagnosis</label>
					<select id="diagnosis" name="diagnosis" class="first-underline">
						<option value="0">All Diagnoses</option>
						<option value="1160664">CLINICALLY DIAGNOSED</option>
						<option value="1160663">BACTERIOLOGICAL CONFIRMED</option>
					</select>
				</field>
				
				<field class="clear both">
					<label for="outcome">Outcome</label>
					<select id="outcome" name="outcome" class="first-underline">
						<option value="">All Outcomes</option>
						<option value="57">TREATMENT COMPLETE</option>
						<option value="37">PATIENT CURED</option>
						<option value="110">PATIENT DIED</option>
						<option value="188">LOST TO FOLLOWUP</option>
						<option value="147">TREATMENT FAILURE</option>
						<option value="171">PATIENT NOT EVALUATED</option>
					</select>
				</field>
			</div>
			
			
			<div class="rows4">
				<field>
					<label for="artstatus">ART Status</label>
					<select id="artstatus" name="artstatus" class="first-underline">
						<option value="0">All Statuses</option>
						<option value="127">STARTED ON ART</option>
						<option value="126">NOT STARTED ART</option>
					</select>
				</field>
				
				<field>
					<label for="cptstatus">CPT Status</label>
					<select id="cptstatus" name="cptstatus" class="first-underline">
						<option value="0">All Statuses</option>
						<option value="127">STARTED ON CPT</option>
						<option value="126">NOT STARTED CPT</option>
					</select>
				</field>
			</div>
			
		</div>
		
		<div id="register" style="display: block; margin-top:3px;">
			<table id="registerList">
				<thead>
					<th>#</th>
					<th>REG.DATE</th>
					<th>TBMU NO.</th>
					<th>NAME</th>
					<th>SEX</th>
					<th>AGE</th>
					<th>ADDRESS</th>
					<th>FACILITY</th>
					<th>SUPPORTER</th>
					<th>DOT</th>
					<th>STARTED</th>
					<th>CATEGORY</th>
					<th>SITE</th>
					<th>TYPE</th>
					<th>COMPLETED</th>
					<th>OUTCOME</th>
					<th>ART</th>
					<th>CPT</th>
				</thead>
				
				<tbody>			
				</tbody>
			</table>
		</div>
    </div>
</div>