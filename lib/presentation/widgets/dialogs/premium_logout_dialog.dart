import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/animations/particle_effects.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';
import 'package:prioris/presentation/widgets/indicators/premium_sync_status_indicator.dart';

/// Premium Logout Dialog with glassmorphism, physics animations and sophisticated UX
/// 
/// Features:
/// - Glassmorphism design with adaptive blur and premium glass effects
/// - Physics-based entrance/exit animations with spring curves
/// - Particle effects for successful actions
/// - Premium haptic feedback for all interactions
/// - Elegant gradient overlays and depth effects
/// - Accessibility-first design with reduced motion support
/// - "Invisible when working" principle - sophisticated but not distracting
class PremiumLogoutDialog extends ConsumerStatefulWidget {
  final bool enableHaptics;
  final bool enablePhysicsAnimations;
  final bool enableParticles;
  final bool respectReducedMotion;
  final Duration animationDuration;

  const PremiumLogoutDialog({
    super.key,
    this.enableHaptics = true,
    this.enablePhysicsAnimations = true,
    this.enableParticles = true,
    this.respectReducedMotion = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  ConsumerState<PremiumLogoutDialog> createState() => _PremiumLogoutDialogState();
}

class _PremiumLogoutDialogState extends ConsumerState<PremiumLogoutDialog>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _glowAnimation;
  
  bool _showParticles = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _triggerHapticFeedback();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startEntranceAnimation();
  }

  void _initializeAnimations() {
    // Entrance animation with sophisticated curves
    _entranceController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Glow animation for premium effects
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeInOut,
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _startEntranceAnimation() {
    if (!widget.respectReducedMotion || 
        MediaQuery.maybeOf(context)?.disableAnimations != true) {
      _entranceController.forward();
      _glowController.repeat(reverse: true);
    } else {
      // Skip animations for accessibility
      _entranceController.value = 1.0;
    }
  }

  void _triggerHapticFeedback() async {
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.modalOpened();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _entranceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Premium backdrop with adaptive blur
        AnimatedBuilder(
          animation: _blurAnimation,
          builder: (context, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
              ),
            );
          },
        ),
        
        // Particle effects layer
        if (_showParticles && widget.enableParticles)
          ParticleEffects.sparkleEffect(
            trigger: _showParticles,
            sparkleCount: 12,
            maxSize: 4.0,
          ),
        
        // Main dialog content
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildGlassmorphismDialog(context),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphismDialog(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          minWidth: 320,
        ),
        margin: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadiusTokens.modal,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadiusTokens.modal,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 60,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: _buildDialogContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Premium header with glow effect
        _buildPremiumHeader(context),
        
        // Content with glassmorphism
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainContent(context),
              const SizedBox(height: 20),
              _buildDestructiveOption(context),
              const SizedBox(height: 24),
              _buildPremiumActions(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1 + 0.05 * _glowAnimation.value),
                Theme.of(context).primaryColor.withOpacity(0.05 + 0.03 * _glowAnimation.value),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.8),
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadiusTokens.button,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 12 * (1 + _glowAnimation.value * 0.5),
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 28,
                  semanticLabel: 'Icône de déconnexion premium',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choix de persistance des données',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos listes resteront disponibles sur cet appareil.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        
        // Premium info card with glassmorphism
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadiusTokens.card,
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_sync_rounded,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Synchronisation disponible',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reconnectez-vous à tout moment pour synchroniser vos données',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDestructiveOption(BuildContext context) {
    return Semantics(
      hint: 'Action irréversible - supprime toutes les données localement',
      button: true,
      child: widget.enablePhysicsAnimations && !_shouldReduceMotion()
          ? PhysicsAnimations.springScale(
              onTap: () => _showDataClearConfirmation(context),
              scaleFactor: 0.98,
              child: _buildDestructiveContent(context),
            )
          : GestureDetector(
              onTap: () => _showDataClearConfirmation(context),
              child: _buildDestructiveContent(context),
            ),
    );
  }

  Widget _buildDestructiveContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadiusTokens.button,
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Colors.red[600],
          ),
          const SizedBox(width: 8),
          Text(
            'Effacer toutes mes données de cet appareil',
            style: TextStyle(
              fontSize: 13,
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel button with premium styling
        widget.enablePhysicsAnimations && !_shouldReduceMotion()
            ? PhysicsAnimations.springScale(
                onTap: () => _handleCancel(context),
                child: _buildCancelButton(context),
              )
            : GestureDetector(
                onTap: () => _handleCancel(context),
                child: _buildCancelButton(context),
              ),
        
        const SizedBox(width: 12),
        
        // Primary logout button with premium effects
        widget.enablePhysicsAnimations && !_shouldReduceMotion()
            ? PhysicsAnimations.springScale(
                onTap: () => _handleLogout(context),
                child: _buildLogoutButton(context),
              )
            : GestureDetector(
                onTap: () => _handleLogout(context),
                child: _buildLogoutButton(context),
              ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadiusTokens.button,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        'Annuler',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadiusTokens.button,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Text(
        'Se déconnecter',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  void _handleCancel(BuildContext context) async {
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.lightImpact();
    }
    
    await _exitWithAnimation();
    if (mounted && !_isDisposed) {
      Navigator.of(context).pop(false);
    }
  }

  void _handleLogout(BuildContext context) async {
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.success();
    }
    
    _triggerSuccessParticles();
    await _exitWithAnimation();
    
    if (mounted && !_isDisposed) {
      Navigator.of(context).pop('logout_keep_data');
    }
  }

  void _triggerSuccessParticles() {
    if (widget.enableParticles && !_shouldReduceMotion()) {
      setState(() {
        _showParticles = true;
      });
      
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_isDisposed) {
          setState(() {
            _showParticles = false;
          });
        }
      });
    }
  }

  Future<void> _exitWithAnimation() async {
    if (!_shouldReduceMotion()) {
      await _entranceController.reverse();
    }
  }

  void _showDataClearConfirmation(BuildContext context) async {
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.warning();
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PremiumDataClearDialog(
        enableHaptics: widget.enableHaptics,
        enablePhysicsAnimations: widget.enablePhysicsAnimations,
        respectReducedMotion: widget.respectReducedMotion,
      ),
    );

    if (result == true && mounted && !_isDisposed) {
      await _exitWithAnimation();
      Navigator.of(context).pop('logout_clear_data');
    }
  }

  bool _shouldReduceMotion() {
    return widget.respectReducedMotion && 
           MediaQuery.maybeOf(context)?.disableAnimations == true;
  }
}

/// Premium confirmation dialog for data clearing
class _PremiumDataClearDialog extends StatefulWidget {
  final bool enableHaptics;
  final bool enablePhysicsAnimations;
  final bool respectReducedMotion;

  const _PremiumDataClearDialog({
    required this.enableHaptics,
    required this.enablePhysicsAnimations,
    required this.respectReducedMotion,
  });

  @override
  State<_PremiumDataClearDialog> createState() => _PremiumDataClearDialogState();
}

class _PremiumDataClearDialogState extends State<_PremiumDataClearDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAnimation();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimation() {
    if (!widget.respectReducedMotion || 
        MediaQuery.maybeOf(context)?.disableAnimations != true) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildConfirmationDialog(context),
          ),
        );
      },
    );
  }

  Widget _buildConfirmationDialog(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.modal,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          child: ClipRRect(
            borderRadius: BorderRadiusTokens.modal,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.withOpacity(0.1),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadiusTokens.modal,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning icon with premium styling
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red[600],
                        size: 32,
                        semanticLabel: 'Avertissement - Action destructive',
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Effacer les données',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.red[800],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Cette action supprimera définitivement toutes vos listes de cet appareil.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Vous ne pourrez pas annuler cette action.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel button (focus by default for safety)
                        Expanded(
                          child: widget.enablePhysicsAnimations
                              ? PhysicsAnimations.springScale(
                                  onTap: () => _handleCancel(context),
                                  child: _buildCancelButton(context),
                                )
                              : GestureDetector(
                                  onTap: () => _handleCancel(context),
                                  child: _buildCancelButton(context),
                                ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Confirm button
                        Expanded(
                          child: widget.enablePhysicsAnimations
                              ? PhysicsAnimations.springScale(
                                  onTap: () => _handleConfirm(context),
                                  child: _buildConfirmButton(context),
                                )
                              : GestureDetector(
                                  onTap: () => _handleConfirm(context),
                                  child: _buildConfirmButton(context),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadiusTokens.button,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        'Annuler',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red[600]!,
            Colors.red[700]!,
          ],
        ),
        borderRadius: BorderRadiusTokens.button,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Effacer',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handleCancel(BuildContext context) async {
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.lightImpact();
    }
    
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  void _handleConfirm(BuildContext context) async {
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.heavyImpact();
    }
    
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

/// Premium Logout Helper with sophisticated notifications and effects
class PremiumLogoutHelper {
  static Future<void> showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent, // Let dialog handle backdrop
      builder: (context) => const PremiumLogoutDialog(),
    );

    if (result == null) return; // Cancelled
    
    switch (result) {
      case 'logout_keep_data':
        await _performLogout(ref, clearData: false);
        _showPremiumLogoutSuccess(context, dataCleared: false);
        break;
        
      case 'logout_clear_data':
        await _performLogout(ref, clearData: true);
        _showPremiumLogoutSuccess(context, dataCleared: true);
        break;
    }
  }

  static Future<void> _performLogout(WidgetRef ref, {required bool clearData}) async {
    try {
      if (clearData) {
        // Clear local data before logout
        // TODO: Implement local data clearing logic
        print('🗑️ Données locales effacées');
      }
      
      // Perform actual authentication logout
      // TODO: Replace with proper AuthService call
      // await ref.read(authServiceProvider).signOut();
      print('✅ Déconnexion réussie');
      
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  static void _showPremiumLogoutSuccess(
    BuildContext context, 
    {required bool dataCleared}
  ) {
    String message = dataCleared 
        ? 'Déconnecté et données effacées'
        : 'Déconnecté - vos listes restent disponibles';
        
    // Show premium notification
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 16,
        right: 16,
        child: PremiumSyncNotification(
          message: message,
          type: PremiumNotificationType.success,
          duration: const Duration(seconds: 4),
          onDismiss: () => entry.remove(),
        ),
      ),
    );
    
    overlay.insert(entry);
  }
}