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
    var NavigatorController;
	var emrMessages = {};
	
    jq(function () {
		emrMessages["requiredField"] = "Required Field";		
        NavigatorController = new KeyboardController();
		
		jq('#birthdate').datepicker({
            yearRange: 'c-100:c',
            maxDate: '0',
            dateFormat: 'dd/mm/yy',
            changeMonth: true,
            changeYear: true,
            constrainInput: false
        }).on("change", function (dateText) {
            jq("#birthdate").val(this.value);
            PAGE.checkBirthDate();
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
		
		PAGE = {
			/** SUBMIT */
			submit: function () {

				// Capitalize fullname and relative name
	//            relativeNameInCaptital = StringUtils.capitalize(jq("#patientRelativeName").val());
				relativeNameInCaptital = (jq("#patientRelativeName").val()).toUpperCase();
				jq("#patientRelativeName").val(relativeNameInCaptital);

				// Validate and submit
				if (this.validateRegisterForm()) {
					jq("#patientRegistrationForm").submit();

				}
			},

			checkNationalID: function () {
				nationalId = jq("#patientNationalId").val();
				jq.ajax({
					type: "GET",
					url: '${ ui.actionLink("registration", "registrationUtils", "main") }',
					dataType: "json",
					data: ({
						nationalId: nationalId
					}),
					success: function (data) {
	//                    jq("#divForNationalId").html(data);
						validateNationalID(data);
					}
				});
			},

			checkPassportNumber: function () {
				passportNumber = jq("#passportNumber").val();
				jq.ajax({
					type: "GET",
					url: '${ ui.actionLink("registration", "registrationUtils", "main") }',
					dataType: "json",
					data: ({
						passportNumber: passportNumber
					}),
					success: function (data) {
	//                    jq("#divForpassportNumber").html(data);
						validatePassportNumber(data);
					}
				});
			},

			/** VALIDATE BIRTHDATE */
			checkBirthDate: function () {
				var submitted = jq("#birthdate").val();
				jq.ajax({
					type: "GET",
					url: '${ ui.actionLink("registration", "registrationUtils", "processPatientBirthDate") }',
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
							jq().toastmessage('showErrorToast', 'Age in wrong format');
							jq("#birthdate").val("");
							goto_previous_tab(5);
						}
					},
					error: function (xhr, ajaxOptions, thrownError) {
						alert(thrownError);
					}

				});
			}
		};
		//Nothing
		
		jq('#gender').val('${gender}');
    });
	
	function goto_next(tabIndex){
		var currents = '';
		
		if (tabIndex == 1) {
            while (jq(':focus') != jq('#address1')) {
				console.log('currents...'+ currents);
				
				
                if (currents == jq(':focus').attr('id')) {
                    NavigatorController.stepForward();
                    jq("#ui-datepicker-div").hide();
                    break;
                }
                else {
                    currents = jq(':focus').attr('id');
                }

                if (jq(':focus').attr('id') == 'address1') {
                    jq("#ui-datepicker-div").hide();
                    break;
                }
                else {
                    NavigatorController.stepForward();
                }
            }
        }
		else if (tabIndex == 2) {
			while (jq(':focus') != jq('#lastItem')) {
                if (currents == jq(':focus').attr('id')) {
                    NavigatorController.stepForward();
                    jq("#ui-datepicker-div").hide();
                    break;
                }
                else {
                    currents = jq(':focus').attr('id');
                }

                if (jq(':focus').attr('id') == 'lastItem') {
                    jq("#ui-datepicker-div").hide();
                    break;
                }
                else {
                    NavigatorController.stepForward();
                }
            }
		}
	}
	
	function goto_previous(tabIndex){
		if (tabIndex == 1) {
            while (jq(':focus') != jq('#identifierValue')) {
                if (jq(':focus').attr('id') == 'identifierValue' || jq(':focus').attr('id') == 'names'  || jq(':focus').attr('id') == 'birthdate') {
                    jq("#ui-datepicker-div").hide();
                    break;
                }
                else {
                    NavigatorController.stepBackward();
                }
            }
        }
        else if (tabIndex == 2) {
			
        }
	}
</script>

<style>
	.toast-item {
		background-color: #222;
	}
	.name {
		color: #f26522;
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
	.simple-form-ui{
		margin-top: 2px;
	}
	.simple-form-ui .field-error, .simple-form-ui form .field-error{
		margin-left: 20%;
	}
	ul#formBreadcrumb {
		width: 25%;
	}
	.simple-form-ui section, .simple-form-ui #confirmation, .simple-form-ui form section, .simple-form-ui form #confirmation {
		box-sizing: border-box;
		width: 75%;
		min-height: 200px;
	}
	form label, .form label {
		display: inline-block;
		width: 19%;
	}
	.simple-form-ui input, .simple-form-ui form input, 
	.simple-form-ui select, .simple-form-ui form select, 
	.simple-form-ui ul.select, .simple-form-ui form ul.select {
		min-width: 0;
		width: 80%;
		height: 38px;
	}
	.simple-form-ui textarea, .simple-form-ui form textarea {
		display: inline-block;
		min-width: 0;
		width: 80%;
	}
	.simple-form-ui section fieldset select:focus, .simple-form-ui section fieldset input:focus, .simple-form-ui section #confirmationQuestion select:focus, .simple-form-ui section #confirmationQuestion input:focus, .simple-form-ui #confirmation fieldset select:focus, .simple-form-ui #confirmation fieldset input:focus, .simple-form-ui #confirmation #confirmationQuestion select:focus, .simple-form-ui #confirmation #confirmationQuestion input:focus, .simple-form-ui form section fieldset select:focus, .simple-form-ui form section fieldset input:focus, .simple-form-ui form section #confirmationQuestion select:focus, .simple-form-ui form section #confirmationQuestion input:focus, .simple-form-ui form #confirmation fieldset select:focus, .simple-form-ui form #confirmation fieldset input:focus, .simple-form-ui form #confirmation #confirmationQuestion select:focus, .simple-form-ui form #confirmation #confirmationQuestion input:focus{
		outline: 0px none #007fff;
	}
	form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus {
		outline: 0px none #007fff;
	}
	.mandatory{
		color: #f00;
		float: right;
		padding-right: 5px;
	}
	.addon {
		color: #f26522;
		display: inline-block;
		float: right;
		margin: 15px 0 0 548px;
		position: absolute;
	}
	.simple-form-ui section fieldset textarea.error, 
	.simple-form-ui section #confirmationQuestion textarea.error, 
	.simple-form-ui #confirmation fieldset textarea.error, 
	.simple-form-ui form section fieldset textarea.error, 
	.simple-form-ui form #confirmation fieldset textarea.error, 
	.simple-form-ui form section #confirmationQuestion textarea.error, 
	.simple-form-ui #confirmation #confirmationQuestion textarea.error, 
	.simple-form-ui form #confirmation #confirmationQuestion textarea.error{
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
			<a href="#">New Patient</a>
		</li>
	</ul>
</div>

<div class="patient-header new-patient-header new-patient-icon">
	<div class="demographics">
		<h1 class="name" style="border-bottom: 1px solid #ddd;">
			<span>NEW PATIENT REGISTRATION &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
		</h1>
		<br/>
	</div>

	<div class="identifiers">
		<em>&nbsp; eTB BMU No.:</em>
		<span>*{TBBMBUNO}</span>
	</div>
</div>

<form method="post" class="simple-form-ui" id="registration-form">
	<section>
		<span class="title">Registration Details</span>
		
		<fieldset class="no-confirmation mother-details">
			<legend>Demographics</legend>
			<field>
				<label for="identifierValue">TB Number:<span class="mandatory">*</span></label>
				<input id="identifierValue" name="identifierValue" type="text" class="required"/>
			</field>
			
			<field>
				<label for="names">Full Names:<span class="mandatory">*</span></label>
				<input id="names" name="patient.name" type="text" value="${names?names:''}" class="required"/>
			</field>
			
			<field>
				<label for="gender">Gender:<span class="mandatory">*</span></label>
				<select id="gender" name="patient.gender" class="required">
					<option value=""></option>
					<option value="M">Male</option>
					<option value="F">Female</option>
				</select>
			</field>
			
			<field>
				<label for="birthdate">Date of Birth:<span class="mandatory">*</span></label>
				<div class="addon"><i class="icon-calendar small">&nbsp;</i></div>
				<input type="text" id="birthdate" name="patient.birthdate" class="required form-textbox1" placeholder="DD/MM/YYYY"/>
			</field>
			
			<div class="onerow" style="margin-top:50px">
				<a class="button confirm" onclick="goto_next(1)" style="float:right; display:inline-block; margin-right: 2px">
					<span>NEXT</span>
				</a>
			</div>
		</fieldset>
		
		<fieldset class="no-confirmation mother-details">
			<legend>Contact Information</legend>
			<field>
				<label for="address1">Address:<span class="mandatory">*</span></label>
				<textarea id="address1" name="address.address1" type="text" class="required"></textarea>
			</field>
			
			<field>
				<label for="cityVillage">City/Village:<span class="mandatory">*</span></label>
				<input id="cityVillage" name="address.cityVillage" type="text" class="required"/>
			</field>
			
			<field>
				<label for="stateProvince">State/Province:</label>
				<input id="stateProvince" name="address.stateProvince" type="text" class=""/>
			</field>
			
			<field>
				<label for="country">Country:</label>
				<input id="country" name="address.country" type="text" class=""/>
			</field>
			
			<field>
				<label for="patientPhoneNumber">Phone Number:</label>
				<input id="patientPhoneNumber" name="person.attribute.16" type="text" class=""/>
			</field>

			<field>
				<label for="identifierValue">Physical Address:</label>
				<textarea id="address2" name="address.address2" type="text" class=""></textarea>
			</field>
			
			<div class="onerow" style="margin-top: 50px">
				<a class="button task" onclick="goto_previous(1);" style="margin-left: 19.5%;">
					<span>PREVIOUS</span>
				</a>

				<a class="button confirm" onclick="goto_next(2);" style="float:right; display:inline-block; margin-right: 2px">
					<span>NEXT</span>
				</a>
			</div>
		</fieldset>		
	</section>
	
	<div id="confirmation" class="confirmation" style="width:74%; padding-top: 0px;">
		<span id="confirmation_label" class="title">Confirmation</span>
		
		<div id="confirmationQuestion" style="display:none">
			<field style="display: none;">
				<input id="lastItem" type="text"/>
			</field>
		</div>
		

		<div class="dashboard onerow">
			<div class="info-section">
				<div class="info-header">
					<i class="icon-diagnosis"></i>

					<h3>Patient Summary</h3>
				</div>

				<div class="info-body">
					<ul>
						<li>
							<span class="status active"></span>
							<div>TBMBU No.:</div>
							<small id="summ_idnt">*{TBBMNUNO}</small>
						</li>
						
						<li>
							<span class="status active"></span>
							<div>Names:</div>
							<small id="summ_name">N/A</small>
						</li>
						
						<li>
							<span class="status active"></span>
							<div>Gender:</div>
							<small id="summ_gend">N/A</small>
						</li>
						
						<li>
							<span class="status active"></span>
							<div>Age:</div>
							<small id="summ_ages">N/A</small>
						</li>
						
						<li>
							<span class="status active"></span>
							<div>Address:</div>
							<small id="summ_adds">N/A</small>
						</li>
						
						<li>
							<span class="status active"></span>
							<div>City/Village:</div>
							<small id="summ_city">N/A</small>
						</li>
					</ul>
				</div>
			</div>
		</div>

		<div class="onerow" style="margin-top: 150px">
			<a class="button task ui-tabs-anchor" onclick="goto_previous(2);">
				<span style="padding: 15px;">PREVIOUS</span>
			</a>

			<a class="button confirm" onclick="PAGE.submit();" style="float:right; display:inline-block; margin-left: 5px;">
				<span>FINISH</span>
			</a>

			<a class="button cancel" onclick="window.location.href = window.location.href" style="float:right; display:inline-block;"/>
				<span>RESET</span>
			</a>
		</div>
	</div>
</form>
