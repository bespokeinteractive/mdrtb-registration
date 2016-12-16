<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Search Patients"])
	
	ui.includeCss("mdrtbregistration", "onepcssgrid.css")
%>

<script>
	jq(function () {
		jq('#as_close').click(function(){
			jq('#dashboard').hide(100);
			jq('#patient-search-form').clearForm();
		});
		
		jq('#advanced').click(function(){
			jq('#dashboard').toggle(300);
			jq('#patient-search-form').clearForm();
		});
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
			else if (tag == 'select')
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
				<input type="text" autocomplete="off" placeholder="Search by ID or Name" id="searchPhrase"
					   style="float:left; width:70%; padding:6px 10px 7px;" onkeyup="ADVSEARCH.startSearch(event);">
				<img id="ajaxLoader" style="display:none; float:left; margin: 3px -4%;" src="${ui.resourceLink("registration", "images/ajax-loader.gif")}"/>

				<div id="advanced" class="advanced" onclick="ShowDashboard();"><i class="icon-filter"></i>ADVANCED SEARCH</div>

				<div id="dashboard" class="dashboard" style="display:none;">
					<div class="info-section">
						<div class="info-header">
							<i class="icon-diagnosis"></i>

							<h3>ADVANCED SEARCH</h3>
							<span id="as_close" onclick="HideDashboard();">
								<div class="identifiers">
									<span style="background:#00463f; padding-bottom: 5px;">x</span>
								</div>
							</span>
						</div>

						<div class="info-body" style="min-height: 100px;">
							<ul>
								<li>
									<div class="onerow" style="padding-top: 0px;">
										<div class="col4">
											<label for="age">Age</label>
											<input id="age" name="age" style="width: 172px; height: 34px;" placeholder="Patient Age">
										</div>
										
										<div class="col4">
											<label for="gender">Gender</label>
											<select style="width: 172px" id="gender" name="gender">
												<option value="">Any</option>
												<option value="M">Male</option>
												<option value="F">Female</option>
											</select>
										</div>

										<div class="col4 last">
											<label for="gender">Previous Visit</label>
											<select style="width: 172px" id="lastVisit">
												<option value="">Anytime</option>
												<option value="31">Last month</option>
												<option value="183">Last 6 months</option>
												<option value="366">Last year</option>
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
											<label for="phoneNumber">Phone No.</label>
											<input id="phoneNumber" name="phoneNumber" style="width: 172px; height: 34px;" placeholder="Phone No.">
										</div>

										<div class="col4 last">
											<label for="lastDayOfVisit">Last Visit</label>
											${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'lastDayOfVisit', id: 'lastDayOfVisit', label: '', useTime: false, defaultToday: false, class: ['newdtp'], endDate: new Date()])}
										</div>
									</div>
									
									<div class="onerow">
										<div class="col4 last">
											<label for="fileNumber">File Number</label>
											<input id="fileNumber" name="fileNumber" style="width: 172px; height: 34px;" placeholder="File Number">
										</div>

										

										
									</div>
								</li>
							</ul>
							<div class="clear"></div>
						</div>
					</div>
				</div>
			</form>

			<div id="patient-search-results" style="display: block; margin-top:3px;">
				<div role="grid" class="dataTables_wrapper" id="patient-search-results-table_wrapper">
					<table id="patient-search-results-table" class="dataTable" aria-describedby="patient-search-results-table_info">
						<thead>
						<tr role="row">
							<th class="ui-state-default" role="columnheader" style="width: 220px;">
								<div class="DataTables_sort_wrapper">Identifier<span class="DataTables_sort_icon"></span></div>
							</th>

							<th class="ui-state-default" role="columnheader">
								<div class="DataTables_sort_wrapper">Name<span class="DataTables_sort_icon"></span></div>
							</th>

							<th class="ui-state-default" role="columnheader" style="width: 60px;">
								<div class="DataTables_sort_wrapper">Age<span class="DataTables_sort_icon"></span></div>
							</th>

							<th class="ui-state-default" role="columnheader" style="width: 60px;">
								<div class="DataTables_sort_wrapper">Gender<span class="DataTables_sort_icon"></span></div>
							</th>

							<th class="ui-state-default" role="columnheader" style="width:120px;">
								<div class="DataTables_sort_wrapper">Last Visit<span class="DataTables_sort_icon"></span></div>
							</th>

							<th class="ui-state-default" role="columnheader" style="width: 100px;">
								<div class="DataTables_sort_wrapper">Action<span class="DataTables_sort_icon"></span></div>
							</th>
						</tr>
						</thead>

						<tbody role="alert" aria-live="polite" aria-relevant="all">
							<tr align="center">
								<td colspan="6">No patients found</td>
							</tr>
						</tbody>
					</table>

				</div>
			</div>
			
			
			
			
			
			
			
			
			
			
			
        </div>
    </div>
</div>