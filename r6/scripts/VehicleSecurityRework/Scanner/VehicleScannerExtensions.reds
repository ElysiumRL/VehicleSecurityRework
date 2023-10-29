module VehicleSecurityRework.Scanner

//Extension to see Quickhack Vulnerabilities
@replaceMethod(scannerDetailsGameController)
  private final func RefreshLayout() -> Void {
    let i: Int32;
    this.StopAnimations();
    if NotEquals(HUDManager.GetActiveMode(this.m_player.GetGame()), ActiveMode.FOCUS) {
      this.PlayOutroAnimation();
    };
    if Equals(this.m_scanningState, gameScanningState.Started) || Equals(this.m_scanningState, gameScanningState.Complete) || Equals(this.m_scanningState, gameScanningState.ShallowComplete) {
      this.GetRootWidget().SetVisible(false);
      i = 0;
      while i < ArraySize(this.m_asyncSpawnRequests) {
        this.m_asyncSpawnRequests[i].Cancel();
        i += 1;
      };
      ArrayClear(this.m_asyncSpawnRequests);
      inkCompoundRef.RemoveAllChildren(this.m_scannerCountainer);
      switch this.m_scannedObjectType {
        case ScannerObjectType.PUPPET:
          this.GetRootWidget().SetVisible(true);
          this.AsyncSpawnScannerModule(n"ScannerNPCHeaderWidget");
          this.AsyncSpawnScannerModule(n"ScannerNPCBodyWidget");
          this.AsyncSpawnScannerModule(n"ScannerBountySystemWidget");
          this.AsyncSpawnScannerModule(n"ScannerRequirementsWidget");
          this.AsyncSpawnScannerModule(n"ScannerAbilitiesWidget");
          this.AsyncSpawnScannerModule(n"ScannerResistancesWidget");
          this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
          //Compatibility for Kiroshi Opticals - Crowd Scanner & Lifepath Bonuses and Gang-Corpo Traits
          this.AsyncSpawnScannerModule(n"ScannerVehicleBody");
          break;
        case ScannerObjectType.DEVICE:
          this.GetRootWidget().SetVisible(true);
          this.AsyncSpawnScannerModule(n"ScannerDeviceHeaderWidget");
          this.AsyncSpawnScannerModule(n"ScannerVulnerabilitiesWidget");
          this.AsyncSpawnScannerModule(n"ScannerRequirementsWidget");
          this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
          break;
        case ScannerObjectType.VEHICLE:
          this.GetRootWidget().SetVisible(true);
          this.AsyncSpawnScannerModule(n"ScannerVehicleBody");
          this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
          //Displays the affiliation ("Faction")
          this.AsyncSpawnScannerModule(n"ScannerNPCBodyWidget");
          //Displays the vulnerability chunks
          this.AsyncSpawnScannerModule(n"ScannerVulnerabilitiesWidget");
          break;
        case ScannerObjectType.GENERIC:
          this.GetRootWidget().SetVisible(true);
          this.AsyncSpawnScannerModule(n"ScannerDeviceHeaderWidget");
          this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
          break;
        default:
          return;
      };
      this.SetTab(this.m_isQuickHackAble && this.m_isQuickHackPanelOpened ? ScannerDetailTab.Hacking : ScannerDetailTab.Data, true);
      inkWidgetRef.SetVisible(this.m_scannerCountainer, !this.m_isQuickHackAble);
      this.m_introAnimProxy = this.PlayLibraryAnimation(n"intro");
      this.m_introAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScannerDetailsShown");
    } else {
      if Equals(this.m_scanningState, gameScanningState.Default) || Equals(this.m_scanningState, gameScanningState.Stopped) {
        this.PlayOutroAnimation();
      };
    };
  }
