/************************************************************************************
 * File Name   		: User_tr
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-11-13
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-13       ugon96@gmail.com         Initial Version
*************************************************************************************/

public with sharing class User_tr extends TriggerHandler {
    public User_tr() {
        listNew = (List<User>) trigger.new;
        mapOld = (Map<Id, User>) trigger.oldMap;
        listOld = (List<User>) trigger.old;
    }
    /** TriggerHandler */
    private List<User> listNew { get; set; }
    private List<User> listOld { get; set; }
    private Map<Id, User> mapOld { get; set; }

    public override void afterInsert() {
        addPartnerUserToPublicGroup();
    }
    public override void afterUpdate() {
        addPartnerUserToPublicGroup();
    }

    // Asset 의 Approval Process 를 위해(Create Registration Save 이후 TM의 승인) Partner User_tr Public Group 에 추가해준다.
    public void addPartnerUserToPublicGroup() {
        System.debug('addPartnerUserToPublicGroup() run');

        List<Profile> listProfile = [SELECT Id FROM Profile WHERE Name = 'TYM Dealer'];
        System.debug('listProfile :: ' + listProfile);
        List<Id> listProfileId = new List<Id>();
        for (Profile objProfile : listProfile) {
            listProfileId.add(objProfile.Id);
        }
        System.debug('listProfileId :: ' + listProfileId);
        List<GroupMember> listPartnerGroupMember = new List<GroupMember>();
        List<User> listTargetUser = new List<User>();
        if (Trigger.isInsert) {
            // 파트너 사용자 생성시 그룹에 넣어줌.
            for (User objUser : listNew) {
                if (listProfileId.contains(objUser.ProfileId) && objUser.IsActive) {
                    listTargetUser.add(objUser);
                }
            }
        } else if (Trigger.isUpdate) {
            // IsActive 활성화시 그룹에 넣어줌
            for (User objUser : listNew) {
                if (mapOld.get(objUser.Id).IsActive != objUser.IsActive && objUser.IsActive) {
                    listTargetUser.add(objUser);
                }
            }
        }
        if (listTargetUser.size() > 0) {
            Group objPartnerGroup = [SELECT Id FROM Group WHERE DeveloperName = 'PartnerUserGroup' LIMIT 1];
            System.debug('objPartnerGroup :: ' + objPartnerGroup);
            for (User objUser : listTargetUser) {
                GroupMember objGM = new GroupMember(
                        UserOrGroupId = objUser.Id,
                        GroupId = objPartnerGroup.Id
                );
                listPartnerGroupMember.add(objGM);
            }
            System.debug('listPartnerGroupMember :: ' + listPartnerGroupMember);
            if (listPartnerGroupMember.size() > 0) {
                insert listPartnerGroupMember;
            }
        }

    }
}