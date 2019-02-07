<template>
    <section class="container">
        <h2 class="content__heading sb30">{{ $t('OracleEdit') }}</h2>
        <div class="form-group sb30">
            <label>{{ $t('OracleAddress') }}</label>
            <b-field>
                 <input type="text" class="form-control"/>
            </b-field>
        </div>

        <div class="form-group sb30">
            <label>{{ $t('OracleInfo') }}</label>
            <b-field>
                 <textarea type="text" class="form-control"/>
            </b-field>
        </div>



        <b-field class="ProjectSwitch sb30">
            <b-select @input="FetchProject" :placeholder="$t('OracleSelectType')" expanded>
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
            </b-select>
        </b-field>

        <b-field class="ProjectSwitch sb30">
            <b-select @input="FetchProject" :placeholder="$t('OracleSelectStatus')" expanded>
                <option>0</option>
                <option>1</option>
            </b-select>
        </b-field>
    </section>
</template>

<script>
    import './default.scss';
    import ProjectSwitch from 'bem/ProjectSwitch';
    import Receiving from 'bem/Receiving';
    import {CONFIRM_TX} from "store/modules/Transactions.js";
    import Steps from "bem/Steps";

    import {createNamespacedHelpers} from 'vuex';
    import {isZeroAddress, errorMessageSubstitution} from 'lib/utils';

    const ConfigNS = createNamespacedHelpers('Config');
    const LedgerNS = createNamespacedHelpers("Ledger");
    const AccountNS = createNamespacedHelpers("Account");
    const ProjectNS = createNamespacedHelpers("Project");
    const LangNS = createNamespacedHelpers("Lang");

    export default {
        name: 'ProjectDashboardReceiving',
        components: {
            ProjectSwitch,
            Receiving,
            Steps
        },
        computed: {
            ...LedgerNS.mapState({
                ledgerMeta: 'meta',
            }),
            ...AccountNS.mapState({
                currentAccount: "currentAccount",
                accountMeta: "meta",
                currentAccountData: "currentAccountData",
            }),
            ...ProjectNS.mapState({
                currentProject: "currentProject",
                ProjectMeta: "meta",
            }),
            ...LangNS.mapState({
                langMeta: 'meta'
            }),
            ...ConfigNS.mapState({
                W12Lister: "W12Lister"
            }),

            isError() {
                return this.ledgerMeta.loadingError || this.ProjectMeta.loadingError || this.accountMeta.loadingError;
            },
            isLoading() {
                return (
                    this.accountMeta.loading
                    || this.ProjectMeta.loading
                );
            },
            isCurrentToken(){
                return typeof CurrentToken !== 'undefined';
            },
            typeDecimals() {
                if (!this.createForm.decimals) return '';

                return this.isTokenDecimalsValid ? "" : "is-danger";
            },
            messageDecimals() {
                if (!this.createForm.decimals) return '';

                return this.isTokenDecimalsValid ? "" : this.$t("ErrorValidDecimals");
            },
            typeName() {
                if (!this.createForm.name) return '';

                return this.isTokenNameValid ? "" : "is-danger";
            },
            messageName() {
                if (!this.createForm.name) return '';

                return this.isTokenNameValid ? "" : this.$t("ErrorTokenNameIsNotValid");
            },
            typeSymbol() {
                if (!this.createForm.symbol) return '';

                return this.isTokenSymbolValid ? "" : "is-danger";
            },
            messageSymbol() {
                if (!this.createForm.symbol) return '';

                return this.isTokenSymbolValid ? "" : this.$t("ErrorTokenSymbolsIsNotValid");
            },
            isErrorTx() {
                return this.TransactionsList && this.TransactionsList.length
                    ? this.TransactionsList.find((tr) => {
                        return tr.name
                        && tr.hash
                        && tr.status
                        && tr.name === "createToken"
                        && tr.status === "error"
                            ? tr
                            : false
                    })
                    : false;
            },
            isPendingTx() {
                return this.TransactionsList && this.TransactionsList.length
                    ? this.TransactionsList.find((tr) => {
                        return tr.name
                        && tr.hash
                        && tr.status
                        && tr.name === "createToken"
                        && tr.status === "pending"
                            ? tr
                            : false
                    })
                    : false;
            },
            disable() {
                return !this.isTokenNameValid
                    || !this.isTokenSymbolValid
                    || !this.isTokenDecimalsValid
                    || !this.isTokenMintAmountValid;
            },
            nextStepBlocked(){
                return this.isPendingTx ? this.$t('StepsBlockedTx') : false;
            }

        },
        watch: {
            'currentAccount': {
                handler: 'handleCurrentAccountChange',
                immediate: true
            },
            'ProjectMeta': {
                handler: 'handleProjectMetaChange',
                deep: true,
            }
        },
        methods: {
            ...LedgerNS.mapActions({
                LedgerFetch: 'fetch',
            }),
            ...AccountNS.mapActions({
                watchCurrentAccount: 'watch',
                updateAccountData: 'updateAccountData',
            }),
            ...ProjectNS.mapActions({
                updateTokensApprovedToPlaceValue: 'updateTokensApprovedToPlaceValue',
                updatePlacedTokenStatus: 'updatePlacedTokenStatus',
                fetchProject: "fetchProject",
                ProjectFetchList: "fetchList",
                fetchCrowdSaleAddressAndInfo: "fetchCrowdSaleAddressAndInfo",
                updateTokenInfo: "updateTokenInfo",
                updateOwnerBalance: "updateOwnerBalance",
                upTokenAfterEvent: "upTokenAfterEvent",
                fetchCrowdSaleStagesList: "fetchCrowdSaleStagesList",
                fetchCrowdSaleMilestonesList: "fetchCrowdSaleMilestonesList",
                updateReceivingInformation: "updateReceivingInformation",
                updateFundInformation: "updateFundInformation",
                FetchProjectByCurrentToken: "fetchProjectByCurrentToken"
            }),
            async handleCurrentAccountChange(currentAccount) {
                if(currentAccount){
                    if(this.isCurrentToken){
                        await this.FetchProjectByCurrentToken(CurrentToken);
                    } else {
                        await this.ProjectFetchList();
                    }
                }
            },
            async handleProjectMetaChange(meta) {
                if(!meta.loadingProject) {
                    await this.updateAccountData();
                    this.unsubscribeFromEvents();
                    await this.subscribeToEvents();
                    window.dispatchEvent(new Event('resize'));
                }
            },
            unsubscribeFromEvents() {
                if (!this.subscribedEvents) return;

                if (this.subscribedEvents.ApprovalW12Event) {
                    this.subscribedEvents.ApprovalW12Event.stopWatching();
                }
                if (this.subscribedEvents.UnsoldTokenReturned) {
                    this.subscribedEvents.UnsoldTokenReturned.stopWatching();
                }
                if (this.subscribedEvents.Exchange) {
                    this.subscribedEvents.Exchange.stopWatching();
                }

                this.subscribedEvents = null;
            },
            async subscribeToEvents() {
                if (!this.currentProject) return;
                if (this.subscribedEvents) return;

                this.subscribeToEventsLoading = true;

                try {
                    const {W12CrowdsaleFactory, W12ListerFactory, W12TokenFactory, W12AtomicSwapFactory, TokenExchangerFactory} = await this.LedgerFetch(this.currentProject.version);
                    let ApprovalW12Event = null;
                    let UnsoldTokenReturned = null;
                    let Exchange = null;

                    if (!isZeroAddress(this.currentProject.tokenCrowdsaleAddress)) {
                        const W12Crowdsale = W12CrowdsaleFactory.at(this.currentProject.tokenCrowdsaleAddress);
                        UnsoldTokenReturned = W12Crowdsale.events.UnsoldTokenReturned(null, null, this.onUnsoldTokenReturnedEvent);
                        const W12Lister = W12ListerFactory.at(this.currentProject.listerAddress);
                        const swapAddress = await W12Lister.swap();
                        const W12AtomicSwap = TokenExchangerFactory ? TokenExchangerFactory.at(swapAddress):W12AtomicSwapFactory.at(swapAddress);
                        Exchange = W12AtomicSwap.events.Exchange(null, null, this.onExchangeEvent);
                    }

                    if (!isZeroAddress(this.currentProject.wTokenAddress)) {
                        const W12Token = W12TokenFactory.at(this.currentProject.wTokenAddress);
                        ApprovalW12Event = W12Token.events.Approval(null, null, this.onApprovalW12Event);
                    }

                    this.subscribedEvents = {
                        Exchange,
                        ApprovalW12Event,
                        UnsoldTokenReturned,
                    };
                } catch (e) {
                    this.error = errorMessageSubstitution(e);
                }

                this.subscribeToEventsLoading = false;
            },

            async onApprovalW12Event(error, result) {
                if (!error) {
                    await this.$store.dispatch('Cache/blockNumberUp');
                    const tx = result.transactionHash;
                    await this.updateTokensApprovedToPlaceValue({Token: this.currentProject});
                    await this.updateAccountData();
                    this.$store.commit(`Transactions/${CONFIRM_TX}`, tx);
                }
            },
            async onExchangeEvent(error, result){
                if (!error) {
                    await this.$store.dispatch('Cache/blockNumberUp');
                    await this.updateFundInformation({Token: this.currentProject});
                    await this.updateAccountData();
                    const tx = result.transactionHash;
                    this.$store.commit(`Transactions/${CONFIRM_TX}`, tx);
                }
            },
            async onTrancheReleasedEvent(error, result) {
                if (!error) {
                    await this.$store.dispatch('Cache/blockNumberUp');
                    await this.updateFundInformation({Token: this.currentProject});
                    await this.updateAccountData();
                    const tx = result.transactionHash;
                    this.$store.commit(`Transactions/${CONFIRM_TX}`, tx);
                }
            },
            async onUnsoldTokenReturnedEvent(error, result) {
                if (!error) {
                    await this.$store.dispatch('Cache/blockNumberUp');
                    await this.updateReceivingInformation({Token: this.currentProject});
                    await this.updateAccountData();
                    const tx = result.transactionHash;
                    this.$store.commit(`Transactions/${CONFIRM_TX}`, tx);
                }
            },
        },
        async created() {
            await this.watchCurrentAccount();
        },
    };
</script>
