import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/aprendiz.dart';
import '../services/aprendiz_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AprendizService _service = AprendizService();

  List<Aprendiz> _aprendices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarAprendices();
  }

  Future<void> _cargarAprendices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.obtenerAprendices();

      if (!mounted) return;
      setState(() => _aprendices = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _mensajeError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mensajeError(Object error) {
    if (error is PostgrestException) {
      return error.message;
    }
    return 'Ocurrió un error al consultar los aprendices.';
  }

  Future<void> _mostrarFormulario({Aprendiz? aprendiz}) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => AprendizFormDialog(aprendiz: aprendiz),
    );

    if (resultado == true) {
      await _cargarAprendices();
    }
  }

  Future<void> _eliminar(Aprendiz aprendiz) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar aprendiz'),
          content: Text(
            '¿Seguro que deseas eliminar a ${aprendiz.nombre1} '
            '${aprendiz.apellido1}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _service.eliminarAprendiz(aprendiz.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aprendiz eliminado correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _cargarAprendices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mensajeError(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  String _nombreCompleto(Aprendiz a) {
    return [
      a.nombre1,
      a.nombre2,
      a.apellido1,
      a.apellido2,
    ].where((item) => item != null && item!.trim().isNotEmpty).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Aprendices'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _loading ? null : _cargarAprendices,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _cargarAprendices,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_aprendices.isEmpty) {
      return const Center(
        child: Text('No hay aprendices registrados.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarAprendices,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _aprendices.length,
        itemBuilder: (context, index) {
          final aprendiz = _aprendices[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(aprendiz.nombre1[0].toUpperCase()),
              ),
              title: Text(_nombreCompleto(aprendiz)),
              subtitle: Text(
                'ID: ${aprendiz.id}\n'
                '${aprendiz.email}\n'
                '${aprendiz.celular} • Género: ${aprendiz.genero}',
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editar') {
                    _mostrarFormulario(aprendiz: aprendiz);
                  } else if (value == 'eliminar') {
                    _eliminar(aprendiz);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline),
                      title: Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AprendizFormDialog extends StatefulWidget {
  final Aprendiz? aprendiz;

  const AprendizFormDialog({
    super.key,
    this.aprendiz,
  });

  @override
  State<AprendizFormDialog> createState() => _AprendizFormDialogState();
}

class _AprendizFormDialogState extends State<AprendizFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _nombre1 = TextEditingController();
  final _nombre2 = TextEditingController();
  final _apellido1 = TextEditingController();
  final _apellido2 = TextEditingController();
  final _celular = TextEditingController();
  final _email = TextEditingController();

  String _genero = 'N';
  DateTime _fechaNacimiento = DateTime(2000, 1, 1);
  bool _saving = false;

  bool get _editando => widget.aprendiz != null;

  @override
  void initState() {
    super.initState();

    final a = widget.aprendiz;
    if (a != null) {
      _id.text = a.id.toString();
      _nombre1.text = a.nombre1;
      _nombre2.text = a.nombre2 ?? '';
      _apellido1.text = a.apellido1;
      _apellido2.text = a.apellido2 ?? '';
      _genero = a.genero.trim().isEmpty ? 'N' : a.genero.trim();
      _fechaNacimiento = a.fechaNacimiento;
      _celular.text = a.celular;
      _email.text = a.email;
    }
  }

  @override
  void dispose() {
    _id.dispose();
    _nombre1.dispose();
    _nombre2.dispose();
    _apellido1.dispose();
    _apellido2.dispose();
    _celular.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() => _fechaNacimiento = fecha);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final aprendiz = Aprendiz(
      id: int.parse(_id.text.trim()),
      nombre1: _nombre1.text.trim(),
      nombre2: _nombre2.text.trim().isEmpty ? null : _nombre2.text.trim(),
      apellido1: _apellido1.text.trim(),
      apellido2: _apellido2.text.trim().isEmpty ? null : _apellido2.text.trim(),
      genero: _genero,
      fechaNacimiento: _fechaNacimiento,
      celular: _celular.text.trim(),
      email: _email.text.trim(),
    );

    try {
      final service = AprendizService();

      if (_editando) {
        await service.actualizarAprendiz(aprendiz);
      } else {
        await service.crearAprendiz(aprendiz);
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Aprendiz actualizado correctamente.'
                : 'Aprendiz creado correctamente.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is PostgrestException
                ? e.message
                : 'No fue posible guardar el aprendiz.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _obligatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    return null;
  }

  String? _validarId(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa el ID.';
    if (int.tryParse(value.trim()) == null) return 'Debe ser un número.';
    return null;
  }

  String? _validarCelular(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el celular.';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Debe tener exactamente 10 dígitos.';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el correo.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = DateFormat('dd/MM/yyyy').format(_fechaNacimiento);

    return AlertDialog(
      title: Text(_editando ? 'Editar aprendiz' : 'Nuevo aprendiz'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _id,
                  enabled: !_editando,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: _validarId,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nombre1,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Primer nombre',
                  ),
                  validator: _obligatorio,
                ),
                TextFormField(
                  controller: _nombre2,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Segundo nombre (opcional)',
                  ),
                ),
                TextFormField(
                  controller: _apellido1,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Primer apellido',
                  ),
                  validator: _obligatorio,
                ),
                TextFormField(
                  controller: _apellido2,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Segundo apellido (opcional)',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _genero,
                  decoration: const InputDecoration(
                    labelText: 'Género',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'N', child: Text('N - Masculino')),
                    DropdownMenuItem(value: 'F', child: Text('F - Femenino')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _genero = value);
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _seleccionarFecha,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(fechaTexto),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _celular,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                  ),
                  validator: _validarCelular,
                ),
                TextFormField(
                  controller: _email,
                  maxLength: 50,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: _validarEmail,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _guardar,
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_editando ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
}
