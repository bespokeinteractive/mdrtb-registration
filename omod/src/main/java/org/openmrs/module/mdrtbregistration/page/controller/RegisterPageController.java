package org.openmrs.module.mdrtbregistration.page.controller;

import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Created by Dennis Henry on 12/15/2016.
 */
public class RegisterPageController {
    public String get(
            @RequestParam(value = "names", required=false) String names,
            @RequestParam(value = "gender", required=false) String gender,
            @RequestParam(value = "birthdate", required=false) String birthdate,
            PageModel model,
            UiUtils ui) {

        if (gender.equals("undefined")){
            gender="";
        }

        model.addAttribute("names", names);
        model.addAttribute("gender", gender);
        model.addAttribute("birthdate", birthdate);

        return null;
    }
}
