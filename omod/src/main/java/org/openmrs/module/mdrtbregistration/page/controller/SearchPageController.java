package org.openmrs.module.mdrtbregistration.page.controller;

import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Created by Dennis Henry on 12/14/2016.
 */
public class SearchPageController {
    public String get(
            @RequestParam(value = "phrase", required=false) String phrase,
            PageModel model,
            UiUtils ui) {
        model.addAttribute("phrase", phrase);
        return null;
    }
}
