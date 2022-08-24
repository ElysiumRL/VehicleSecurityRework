module VehicleSecurityRework.Scanner

//Extension to see Quickhack Vulnerabilities
@replaceMethod(scannerDetailsGameController)
  public final func RefreshLayout() -> Void {
	let i: Int32;
	this.BreakAniamtions();
	if NotEquals(HUDManager.GetActiveMode(this.m_gameInstance), ActiveMode.FOCUS) {
	  this.PlayCloseScannerAnimation();
	};
	if Equals(this.m_scanningState, gameScanningState.Complete) || Equals(this.m_scanningState, gameScanningState.ShallowComplete) || Equals(this.m_scanningState, gameScanningState.Started) {
	  i = 0;
	  while i < ArraySize(this.m_asyncSpawnRequests) {
		this.m_asyncSpawnRequests[i].Cancel();
		i += 1;
	  };
	  ArrayClear(this.m_asyncSpawnRequests);
	  inkCompoundRef.RemoveAllChildren(this.m_scannerCountainer);
	  inkCompoundRef.RemoveAllChildren(this.m_quickhackContainer);
	  inkWidgetRef.SetVisible(this.m_bg, true);
	  this.GetRootWidget().SetVisible(false);
	  ArrayPush(this.m_asyncSpawnRequests, this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_quickhackContainer), n"QuickHackDescription"));
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
		  
		  //NPCBody : Affiliation (wanted a fun thing but it doesn't fit the mod & it's broken because of tweak db sadge)
		  //this.AsyncSpawnScannerModule(n"ScannerNPCBodyWidget");
		  //Added this
		  //Displays the vulnerability chunks
		  this.AsyncSpawnScannerModule(n"ScannerVulnerabilitiesWidget");
		  ////

		  break;
		case ScannerObjectType.GENERIC:
		  this.GetRootWidget().SetVisible(true);
		  this.AsyncSpawnScannerModule(n"ScannerDeviceHeaderWidget");
		  this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
		  inkWidgetRef.SetVisible(this.m_toggleDescirptionHackPart, false);
		  break;
		default:
		  return;
	  };
	  this.m_showScanAnimProxy = this.PlayLibraryAnimation(n"intro");
	  this.m_showScanAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScannerDetailsShown");
	};
	if Equals(this.m_scanningState, gameScanningState.Stopped) || Equals(this.m_scanningState, gameScanningState.Default) {
	  this.PlayCloseScannerAnimation();
	};
  }

//Module to add Remote Wheel for Vehicles
@replaceMethod(QuickhackModule)
  protected func Process(out task: HUDJob, mode: ActiveMode) -> Void {
	let instruction: ref<QuickhackInstance>;
	if !IsDefined(task.actor) {
	  return;
	};
	if IsDefined(this.m_hud.GetCurrentTarget()) && 
	(Equals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.DEVICE)
	|| Equals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.BODY_DISPOSAL_DEVICE)
	|| Equals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.PUPPET)
	//Added this
	|| Equals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.VEHICLE)) {
	////
	  if task.actor == this.m_hud.GetCurrentTarget() {
		if this.m_hud.GetCurrentTarget().GetShouldRefreshQHack() {
		  this.m_calculateClose = true;
		  this.m_hud.GetCurrentTarget().SetShouldRefreshQHack(false);
		  instruction = task.instruction.quickhackInstruction;
		  if IsDefined(instruction) && IsDefined(task.actor) {
			instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
			instruction.SetContext(this.BaseOpenCheck());
		  };
		};
	  };
	} else {
	  if this.m_calculateClose {
		if !IsDefined(this.m_hud.GetCurrentTarget())
		|| NotEquals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.DEVICE)
		|| NotEquals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.BODY_DISPOSAL_DEVICE)
		|| NotEquals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.PUPPET)
		//And this
		|| NotEquals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.VEHICLE)
		////
		 {
		  this.m_calculateClose = false;
		  this.m_hud.GetLastTarget().SetShouldRefreshQHack(true);
		  QuickhackModule.SendRevealQuickhackMenu(this.m_hud, this.m_hud.GetPlayer().GetEntityID(), false);
		};
	  };
	};
  }

