package org.openmrs.module.mdrtbregistration.page.controller;

import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Created by daugm on 2/11/2017.
 */
public class ActivePageController {
    public String get(
            @RequestParam(value = "program") Integer program,
            PageModel model,
            UiUtils ui) {
        model.addAttribute("program", program);
        return null;
    }
}
