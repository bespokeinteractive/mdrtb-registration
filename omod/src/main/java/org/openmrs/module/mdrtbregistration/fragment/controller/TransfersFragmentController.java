package org.openmrs.module.mdrtbregistration.fragment.controller;

import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.api.ProgramWorkflowService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.mdrtb.service.MdrtbService;
import org.openmrs.module.mdrtbdashboard.MdrtbTransferWrapper;
import org.openmrs.module.mdrtbdashboard.api.MdrtbDashboardService;
import org.openmrs.module.mdrtb.model.PatientProgramDetails;
import org.openmrs.module.mdrtb.model.PatientProgramTransfers;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by Dennys Henry
 * Created on 10/2/2017.
 */
public class TransfersFragmentController {
    MdrtbDashboardService dashboardService = Context.getService(MdrtbDashboardService.class);
    MdrtbService mdrtbService = Context.getService(MdrtbService.class);
    ProgramWorkflowService workflowService = Context.getProgramWorkflowService();

    public SimpleObject getPatientTransferDetails(@RequestParam(value = "transferId") Integer id){
        PatientProgramTransfers ppt = mdrtbService.getPatientProgramTransfers(id);
        PatientProgramDetails ppd = mdrtbService.getPatientProgramDetails(ppt.getPatientProgram());
        Patient patient = ppt.getPatientProgram().getPatient();
        String names = patient.getGivenName() + " " + patient.getFamilyName();
        if (patient.getMiddleName() != null){
            names += " " + patient.getMiddleName();
        }

        return SimpleObject.create("names", names.toUpperCase(), "identifier", ppd.getTbmuNumber(), "from", ppt.getLocation().getName().toUpperCase());
    }

    public List<SimpleObject> searchTransferredPatients(UiUtils ui,
                                                        UiSessionContext session) {
        List<PatientProgramTransfers> transfers = mdrtbService.getPatientProgramTransfers(session.getSessionLocation(), false);
        List<MdrtbTransferWrapper> wrapperList = mdrtbTransferWithDetails(transfers);

        return SimpleObject.fromCollection(wrapperList, ui, "wrapperIdentifier", "wrapperNames", "wrapperDated", "patientTransfers.id", "patientTransfers.patientProgram.id", "patientTransfers.patientProgram.patient.patientId", "patientTransfers.patientProgram.patient.age", "patientTransfers.patientProgram.patient.gender", "patientTransfers.patientProgram.patient.names", "patientTransfers.patientProgram.location.name");
    }

    private List<MdrtbTransferWrapper> mdrtbTransferWithDetails(List<PatientProgramTransfers> mdrtbTransfers){
        List<MdrtbTransferWrapper> wrappers = new ArrayList<MdrtbTransferWrapper>();
        for (PatientProgramTransfers transfers : mdrtbTransfers){
            MdrtbTransferWrapper tw = new MdrtbTransferWrapper(transfers);
            wrappers.add(tw);
        }

        return wrappers;
    }

    public SimpleObject voidTransfers(@RequestParam(value = "transferId") Integer transferId,
                                      @RequestParam(value = "reasons") String reasons,
                                      UiSessionContext session){
        PatientProgramTransfers ppt = mdrtbService.getPatientProgramTransfers(transferId);
        PatientProgramDetails ppd = mdrtbService.getPatientProgramDetails(ppt.getPatientProgram());
        PatientProgram pp = ppt.getPatientProgram();
        pp.setDateCompleted(null);
        pp.setOutcome(null);
        ppd.setOutcome(null);

        this.workflowService.savePatientProgram(pp);
        this.mdrtbService.savePatientProgramDetails(ppd);

        ppt.setVoided(true);
        ppt.setVoidedOn(new Date());
        ppt.setVoidedBy(Context.getAuthenticatedUser().getId());
        ppt.setVoidReason(reasons);
        this.mdrtbService.savePatientProgramTransfers(ppt);

        return SimpleObject.create("status", "success", "message", "Transfer successfully voided!");
    }
}
