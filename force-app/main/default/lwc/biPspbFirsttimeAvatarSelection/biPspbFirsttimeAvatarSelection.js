import { LightningElement, wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CURRENT_USER from '@salesforce/apex/BI_PSP_CurrentUser.getEnrolleeRecords';
import LOGGED_USER from '@salesforce/apex/BI_PSP_CurrentUser.getCurrentUser';
import AVATAR from '@salesforce/apex/BI_PSPB_EnrolleeAvatarCtrl.updateEnrolleeAvatar';
// Imports resourceUrl to reference external resources for proper rendering and functionality.
import {label} from 'c/biPspbAvatarResources';
// Imports labels for descriptive text or identifiers, enhancing accessibility and user understanding.

export default class BiPspbFirsttimeAvatarSelection extends LightningElement {
	//Proper naming conventions with camel case for all the variable will be followed in the future releases
	avatarImg;
	avatarImage;
	isLoading = true;
	showSpinner = false;
	loginValue;
	loggedPatient;
	chooseAvatar = label.CHOOSE_AVATAR;
	next = label.NEXT;
	errorPage = label.ERROR_PAGE;
	@track imageClass = [
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_AFRO_MAN, dataid: 1 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_AFRO_WOMAN, dataid: 2 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_ARAB_MAN, dataid: 3 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_ARAB_WOMAN, dataid: 4 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_ASIAN_MAN, dataid: 5 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_ASIAN_WOMAN, dataid: 6 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_CAUCASIAN_MAN, dataid: 7 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_CAUCASIAN_WOMAN, dataid: 8 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_INDIAN_MAN, dataid: 9 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_INDIAN_WOMAN, dataid: 10 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_LATINO_MAN, dataid: 11 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ADULT_LATINO_WOMAN, dataid: 12 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_AFRO_MAN, dataid: 13 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_AFRO_WOMAN, dataid: 14 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_ARAB_MAN, dataid: 15 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_ARAB_WOMAN, dataid: 16 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_ASIAN_MAN, dataid: 17 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_ASIAN_WOMAN, dataid: 18 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_CAUCASIAN_MAN, dataid: 19 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_CAUCASIAN_WOMAN, dataid: 20 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_INDIAN_MEN, dataid: 21 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_INDIAN_WOMAN, dataid: 22 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_LATINO_MAN, dataid: 23 },
		{ avatarclass: 'avatar', avatarname: 'avatarName', image: label.ELDER_ADULT_LATINO_WOMAN, dataid: 24 },

	]
	
	results;
	status;
	userAccounts;
	AccountIds;
	//To fetch the data from user tatble 
	@wire(LOGGED_USER)
	wiredLoggedUser({ error, data }) {
		let globalThis = window;
		
		try {
			// Null data is checked and AuraHandledException is thrown from the Apex
			if (data) {
				this.loggedUserData = data;
				if (this.loggedUserData && this.loggedUserData[0]?.BI_PSPB_Caregiver__c === true) {
					this.loggedPatient = false;
				}
				if (this.loggedUserData && this.loggedUserData[0]?.BI_PSPB_Caregiver__c === false) {
					this.loggedPatient = true;
				}
			} else if (error) {

				globalThis.sessionStorage.setItem('errorMessage', error.body.message);
                        globalThis.location?.assign(this.baseUrl +  label.BRANDED_URL + this.errorPage );
			}
			const DEFAULT_SELECTED_AVATAR = this.imageClass.find(avatar => {
				// Assuming this.avatarImg is a JSON string representing an object
				const parsedAvatarImg = 1;
				return avatar.dataid === parsedAvatarImg;
			});
			// If found, set it as selected
			if (DEFAULT_SELECTED_AVATAR) {
				DEFAULT_SELECTED_AVATAR.avatarclass = 'selected';//class
				this.avatarImage = DEFAULT_SELECTED_AVATAR.image;
			}
		} catch (err) {
			globalThis.sessionStorage.setItem('errorMessage', err.body.message);
                        globalThis.location?.assign(this.baseUrl +  label.BRANDED_URL + this.errorPage );
		}
	}

	handleavatare(event) {
		
		this.avatarImg = event.target.getAttribute('data-id')
		for (let i = 0; i < this.imageClass.length; i++) {
			this.imageClass[i].avatarclass = 'avatar';
			
		}
		const CLICKED_AVATAR = this.imageClass.find(avatar => {
				// Assuming this.avatarImg is a JSON string representing an object
				const parsedAvatarImg = JSON.parse(this.avatarImg);
				return avatar.dataid === parsedAvatarImg;
			});
		if (CLICKED_AVATAR) {
			CLICKED_AVATAR.avatarclass = 'selected';//class
			this.avatarImage = CLICKED_AVATAR.image

		}
	}



	
	//To save the selected avatar url to patient in account object
	handleSave() {
		let globalThis = window;
		if (!this.avatarImage) {
			return;
		}
		
		this.showSpinner = true;
		if (this?.avatarImage && this.userAccounts.length > 0) { // Use length property to check if there are user contacts
		
			const ENROLEE_ID = this.userAccounts[0].Id; // Access the Id from the userContacts array
			const NEW_AVATAR_SRC = this.avatarImage; // Corrected variable name
			AVATAR({ enrolleeId: ENROLEE_ID, avatarSrc: NEW_AVATAR_SRC }) // Use newAvatarSrc
			// Null data is checked and AuraHandledException is thrown from the Apex
				// Use newAvatarSrc
				.then(result => {
					try {

							window.location.assign(label.BRANDED_SITEURL + label.QUESTIONNAIRES);
							this.results = result;

						}
						catch (error) {
							globalThis.sessionStorage.setItem('errorMessage', error.body.message);
                        globalThis.location?.assign(this.baseUrl +  label.BRANDED_URL + this.errorPage );
						}


					})
					.catch(error => {
						// Handle error or show an error message
						globalThis.sessionStorage.setItem('errorMessage', error.body.message);
                        globalThis.location?.assign(this.baseUrl +  label.BRANDED_URL + this.errorPage );
					});
		
		}
		//To save the selected avatar url to patient in account object
		
	}

	connectedCallback() {
		let globalThis = window;
		try{
        this.currentPageUrl = globalThis.location?.href;
        this.urlSegments = this.currentPageUrl.split('/');
        this.baseUrl = `${this.urlSegments[0]}//${this.urlSegments[2]}`;
	} catch (error) {
		// Handle error or show an error message
		globalThis.sessionStorage.setItem('errorMessage', error.body.message);
		globalThis.location?.assign(this.baseUrl + label.BRANDED_URL + this.errorPage);
	}
		
    }

    @wire(CURRENT_USER)
    wiredCurrentUser({ error, data }) {
		let globalThis = window;
		try {
			if (data) {
				this.userAccounts = data;
				this.handleCurrentUserResult(data);
			} else if (error) {
				this.handleError(error.body.message);
			}
		} catch (err) {
			// Handle error or show an error message
			globalThis.sessionStorage.setItem('errorMessage', err.body.message);
			globalThis.location?.assign(this.baseUrl + label.BRANDED_URL + this.errorPage);
		}
		
	}
    handleCurrentUserResult(data) {
        if (data) {
			
			this.isLoading = true;
            this.status = data[0].BI_PSPB_PatientStatus__c;

            if (data[0].BI_PSP_Loginattempt__c === 0) {
                this.isLoading = false;
            } else if (data[0].BI_PSP_Loginattempt__c === 1) {
                this.isLoading = true;
                
                this.navigateBasedOnStatus(this.status);
            }
            
        }
    }

    navigateBasedOnStatus(status) {
        const globalThis = window;

        try {
            switch (status) {
                case label.UNASSIGNED_VALUE:
                   globalThis.location.assign(label.UNASSIGNEDSITE_URL);
                    break;
                case label.ACUTE_VALUE:
                   globalThis.location.assign(label.UNASSIGNEDSITE_URL + label.ACUTE_DASHBOARD);
                    break;
                default:
                   globalThis.location.assign(label.BRANDED_SITEURL + label.DASHBOARD);
                    break;
            }
        } catch (error) {
            this.HandleError(error.message);
        } 
    }


	HandleError(error){
		this.showToast(label.ERROR_MESSAGE, error.message, label.ERROR_VARIANT);
	}
	
	showToast(title, message, variant) {
		if (typeof window !== label.UNDIFINED) {
			const event = new ShowToastEvent({
				title: title,
				message: message,
				variant: variant
			});
			this.dispatchEvent(event);
		}
	}
}