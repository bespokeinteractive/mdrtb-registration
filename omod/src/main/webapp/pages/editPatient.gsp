<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Register Patient"])
	
	ui.includeJavascript("uicommons", "handlebars/handlebars.min.js", Integer.MAX_VALUE - 1)
    ui.includeJavascript("uicommons", "navigator/validators.js", Integer.MAX_VALUE - 19)
    ui.includeJavascript("uicommons", "navigator/navigator.js", Integer.MAX_VALUE - 20)
    ui.includeJavascript("uicommons", "navigator/navigatorHandlers.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/navigatorModels.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/navigatorTemplates.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/exitHandlers.js", Integer.MAX_VALUE - 22)
%>

<script>
    jq(function () {
		jq('#birthdate').datepicker({
            yearRange: 'c-100:c',
            maxDate: '0',
            dateFormat: 'dd/mm/yy',
            changeMonth: true,
            changeYear: true,
            constrainInput: false
        }).on("change", function (dateText) {
            jq("#birthdate").val(this.value);
            Page.checkBirthDate();
        });
		
		jq('#names, #gender, #birthdate, #address1, #cityVillage').change(function(){
			jq('#summ_name').text(jq('#names').val());
			jq('#summ_ages').text(jq('#birthdate').val());
			jq('#summ_adds').text(jq('#address1').val());
			jq('#summ_city').text(jq('#cityVillage').val());
			
			if (jq('#gender').val() == 'M'){
				jq('#summ_ages').text('Male');
			}else if (jq('#gender').val() == 'M'){
				jq('#summ_ages').text('Female');
			}else{
				jq('#summ_ages').text('N/A');
			}
		});
		
		Page = {
			/** SUBMIT */
			submit: function () {
				if (jq('#names').val().split(' ').length == 1){
					jq().toastmessage('showErrorToast', 'Kindly provide atleast two names');
					return false;
				}
				if (jq('#gender').val() == ''){
					jq().toastmessage('showErrorToast', 'Kindly specify the patient gender');
					return false;
				}
				if (jq('#birthdate').val() == ''){
					jq().toastmessage('showErrorToast', 'Kindly specify the patient birthdate');
					return false;
				}
				if (jq('#address1').val() == ''){
					jq().toastmessage('showErrorToast', 'Kindly specify the patient Address/Village');
					return false;
				}
				
				jq("#registration-form").submit();
			},

			/** CHECK BIRTHDATE */
			checkBirthDate: function () {
				var submitted = jq("#birthdate").val();
				jq.ajax({
					type: "GET",
					url: '${ ui.actionLink("mdrtbregistration", "registrationUtils", "processPatientBirthDate") }',
					dataType: "json",
					data: ({
						birthdate: submitted
					}),
					success: function (data) {
						if (data.datemodel.error == undefined) {
							if (data.datemodel.estimated) {
								jq("#estimatedAge").html(data.datemodel.age + '<span> (Estimated)</span>');
								jq("#birthdateEstimated").val("true")
							} else {
								jq("#estimatedAge").html(data.datemodel.age);
								jq("#birthdateEstimated").val("false");
							}

							jq("#summ_ages").html(data.datemodel.age);
							jq("#estimatedAgeInYear").val(data.datemodel.ageInYear);
							jq("#birthdate").val(data.datemodel.birthdate);
							jq("#calendar").val(data.datemodel.birthdate);

						} else {
							jq().toastmessage('showErrorToast', 'Birthdate/Age is in wrong format');
							jq("#birthdate").val("");
							jq("#estimatedAge").html("");
						}
					},
					error: function (xhr, ajaxOptions, thrownError) {
						alert(thrownError);
					}

				});
			},
			
			/** VALIDATE PASSED BIRTHDATE */
			validateBirthDate: function () {
				var submitted = jq("#birthdate").val();				
				if (submitted == ''){
					return false;
				}
				
				jq.ajax({
					type: "GET",
					url: '${ ui.actionLink("mdrtbregistration", "registrationUtils", "processPatientBirthDate") }',
					dataType: "json",
					data: ({
						birthdate: submitted
					}),
					success: function (data) {
						if (data.datemodel.error == undefined) {
							if ('${patient.birthdateEstimated}' == 'true') {
								jq("#estimatedAge").html(data.datemodel.age + '<span> (Estimated)</span>');
								jq("#birthdateEstimated").val("true")
							} else {
								jq("#estimatedAge").html(data.datemodel.age);
								jq("#birthdateEstimated").val("false");
							}
							
							jq("#estimatedAgeInYear").val(data.datemodel.ageInYear);
							jq("#birthdate").val(data.datemodel.birthdate);
							jq("#calendar").val(data.datemodel.birthdate);

						} else {
							jq().toastmessage('showErrorToast', 'Birthdate/Age is in wrong format');
							jq("#birthdate").val("");
							jq("#estimatedAge").html("");
							jq("#estimatedAgeInYear").val("");
						}
					},
					error: function (xhr, ajaxOptions, thrownError) {
						alert(thrownError);
					}

				});
			}
		};
		//Nothing
		
		jq('#gender').val('${patient.gender}');		
		Page.validateBirthDate();
    });
</script>

<style>	
	.toast-item {
		background-color: #222;
	}
	.name {
		color: #f26522;
	}
	.new-patient-header {
		padding: 15px 10px 5px;
	}
	.new-patient-header .demographics h1 span {
		font-size: 1.3em;
	}
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}	
	.new-patient-icon::after {
		background: #F9F9F9 url("${ui.resourceLink('mdrtbregistration', 'images/new-patient.jpg')}") no-repeat scroll right bottom / auto 100%;
		content: "";
		opacity: 0.3;
		top: 0;
		left: 0;
		bottom: 0;
		right: 0;
		position: absolute;
		z-index: -1;
	}
	.identifiers{
		margin-top:20px;
	}
	ul#formBreadcrumb {
		width: 25%;
	}
	form label, .form label {
		display: inline-block;
		width: 19%;
	}
	input, form input, 
	select, form select, 
	ul.select, form ul.select {
		min-width: 0;
		display: inline-block;
		width: 80%;
		height: 38px;
	}
	textarea, form textarea {
		display: inline-block;
		min-width: 0;
		width: 80%;
	}
	form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus {
		outline: 0px none #007fff;
	}
	.addon {
		color: #f26522;
		display: inline-block;
		float: right;
		margin: 12px 0 0 510px;
		position: absolute;
	}
	textarea.error{
		border-color: #ff6666;
	}
	.dashboard .info-body li div {
		margin: 1px 0 6px 0;
		display: inline-block;
		width: 150px;
	}
	#names, #summ_name, 
	#address1, #summ_adds, 
	#cityVillage, #summ_city, 
	#stateProvince, #address2{
		text-transform: capitalize;
	}
	#estimatedAge {
		color: #363463;
		padding-left: 20%;
	}
	#estimatedAge span{
		color: #f26522;
	}
	.aside {
		box-sizing: border-box;
		display: inline-block;
		margin: 0;
		padding: 15px 0 0;
		vertical-align: top;
		width: 215px;
	}	
	#left-menu {
		border-left: 1px solid #ccc;
	}
	.content {
		box-sizing: border-box;
		display: inline-block;
		float: right;
		padding: 7px;
		vertical-align: top;
		width: 780px;
	}
	.content article {
	  border-bottom: 1px none #DDD;
	  padding-bottom: 0px;
	  margin-bottom: 0px;
	}
	.content article h1 {
	  margin: 40px 0 20px 0;
	}
	.content article section p {
	  margin-bottom: 10px;
	}
	.content article section p.caution {
	  color: red;
	  padding: 5px;
	}
	.content article section code {
	  display: block;
	  position: relative;
	  margin: 35px 0 0 0;
	  padding: 10px;
	  background-color: #fff;
	  border: 1px solid #ddd;
	  -webkit-border-radius: 2px;
	  -moz-border-radius: 2px;
	  border-radius: 2px;
	}
	.content article section code:after {
	  content: "Example";
	  position: absolute;
	  top: -27px;
	  left: -1px;
	  padding: 3px 7px;
	  font-size: 14px;
	  font-weight: bold;
	  border: 1px solid #ddd;
	  color: #969696;
	  background: #F9F9F9;
	}
	.content article section .example ul.grid > li {
	  display: inline-block;
	  vertical-align: top;
	  text-align: center;
	  width: 200px;
	  margin: 10px;
	}
	.content article section code {
	  background: #F9F9F9;
	  padding: 0;
	}
	.content article section code ol {
	  margin: 0 0 0 50px;
	  display: block;
	  background: #FFF;
	}
	.content article section code ol li {
	  padding: 2px 10px;
	  color: #f9f9f9;
	  line-height: 20px;
	}
	.content article section code ol li:first-child{
		padding-top: 10px;	
	}
	.content article section code ol li:last-child{
		padding: 10px 2px 30px 141px
	}
	.content article section code ol li label{
		color: #363463
	}
	.content article section code ol li span {
	  color: #363463;
	}
	.content article section code ol li span.mandatory{
		color: #f00;
		float: right;
		padding-right: 5px;
	}
	.content article section code ol li span.var, 
	.content article section code ol li span.tag {
	  color: teal;
	}
	.content article section code ol li span.val {
	  color: #D14;
	}
	.content article section code ol li span.comm {
	  color: #888;
	}
	.content article section code:after {
	  font-family: "OpenSans";
	  content: "Patient Details";
	}
	.content article section#colors-example ul li {
	  display: inline-block;
	  margin-right: 20px;
	}
	.content article section#colors-example ul li span {
	  width: 100px;
	  height: 100px;
	  border-radius: 50%;
	  background: white;
	  display: block;
	  float: left;
	}
	.content article section#colors-example ul li p {
	  clear: both;
	  text-align: center;
	  padding: 5px;
	  font-size: 12px;
	  color: #999;
	}
	code, kbd, pre, samp {
		font-family: "OpenSans",Arial,sans-serif;
		font-size: 1em;
	}
	a.button.confirm,
	a.button.task,
	a.button.cancel{
		line-height: 1.5em;
	}
	ul.left-menu li .menu-date {
		font-size: 1em;
	}
	ul.left-menu li .menu-title {
		font-size: 0.75em;
	}
	ul.left-menu li:last-of-type {
		height: 150px;
	}
</style>

<div class="clear"></div>
<div class="example">
	<ul id="breadcrumbs">
		<li>
			<a href="${ui.pageLink('referenceapplication','home')}">
				<i class="icon-home small"></i></a>
		</li>
		
		<li>
			<i class="icon-chevron-right link"></i>
			<a href="${ui.pageLink('registration','patientRegistration')}">Registration</a>
		</li>
		
		<li>
			<i class="icon-chevron-right link"></i>
			<a href="#">Edit Patient</a>
		</li>
	</ul>
</div>

<div class="patient-header new-patient-header new-patient-icon">
	<div class="demographics">
		<h1 class="name" style="border-bottom: 1px solid #ddd;">
			<span>EDIT PATIENT DETAILS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
		</h1>
		<br/>
	</div>

	
</div>

<form method="post" id="registration-form">
	<section >
		<div class="aside">
			<ul id="left-menu" class="left-menu">
				<li class="menu-item selected" visitid="54">
					<span class="menu-date">
						<i class="icon-user"></i>
						Patient Details
					</span>
					<span class="menu-title">
						<i class="icon-globe"></i>
						Demographic Information
					</span>
					<span class="arrow-border"></span>
					<span class="arrow"></span>
				</li>
			
				<li class="menu-item">
					&nbsp;
				</li>
			</ul>
		</div>
		
		<div class="content" style="margin-left: 0px;">
			<section>
				<article id="demographics">
					<section>
						<code>
							<ol>
								<li>
									<label for="names">Full Names:<span class="mandatory">*</span></label>
									<input id="names" name="patient.name" type="text" value="${patient.givenName} ${patient.familyName}${patient.middleName?' '+patient.middleName:''}" class="required"/>
									<input id="idnts" name="patient.id" type="hidden" value="${patient.id}" />
								</li>
								
								<li>
									<label for="gender">Gender:<span class="mandatory">*</span></label>
									<select id="gender" name="patient.gender" class="required">
										<option value=""></option>
										<option value="M">Male</option>
										<option value="F">Female</option>
									</select>
								</li>
								
								<li>
									<label for="birthdate">Date of Birth:<span class="mandatory">*</span></label>
									<div class="addon"><i class="icon-calendar small">&nbsp;</i></div>
									<input type="text" id="birthdate" name="patient.birthdate" value="${birthdate}" class="required form-textbox1" placeholder="DD/MM/YYYY"/>
									<input type="hidden" id="birthdateEstimated" name="patient.birthdateEstimated" value="${patient.birthdateEstimated}" />
									<div id="estimatedAge"></div>
								</li>
								
								<li>
									<label for="address1">Address:<span class="mandatory">*</span></label>
									<textarea id="address1" name="address.address1" type="text" class="required">${patient.getPersonAddress()?patient.getPersonAddress().address1:''}</textarea>									
								</li>
								
								<li>
									<a class="button confirm" onclick="Page.submit();" style="float:right; display:inline-block;">
										<i class="icon-save"></i>
										FINISH
									</a>

									<a class="button cancel" onclick="window.location.href = window.location.href" style="display:inline-block;"/>
										<i class="icon-remove"></i>
										RESET
									</a>
									<div class="clear"></div>
								</li>
							</ol>
						</code><br>
					</section>
				</article>
			</section>
		</div>
	
		<div class="clear"></div>	
	</section>
</form>